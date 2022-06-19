import { CodePipelineCloudWatchActionHandler } from 'aws-lambda';
import * as AWS from 'aws-sdk';
import { getSSMParamValue } from './awsUtils';
import { Octokit } from 'octokit';
import fetch from 'node-fetch';
import { WebClient } from '@slack/web-api';

const pipelinesToMonitor: string[] = [
  'opus-one-cd-orchestration',
  'portal-cicd-pipeline',
  'identity-service-cicd-pipeline',
];

const repoNameByPipeline: Record<string, string> = {
  'opus-one-cd-orchestration': 'lessen-monorepo',
  'portal-cicd-pipeline': 'client-portal-web',
  'identity-service-cicd-pipeline': 'identity-service',
};

const e2eTestRepoNameByPipeline: Record<string, string> = {
  'opus-one-cd-orchestration': 'UIAutomationframework',
  'portal-cicd-pipeline': 'client-portal-web-UIAutomation',
};

const e2eTestActionNameByPipeline: Record<string, string> = {
  'opus-one-cd-orchestration': 'Test_QA',
  'portal-cicd-pipeline': 'E2E_Test',
};

const ssm = new AWS.SSM({ region: 'us-east-1' });
const codePipeline = new AWS.CodePipeline({ region: 'us-east-1' });

async function tryGetSlackMemberIdByEmail(slack: WebClient, email: string): Promise<string | undefined> {
  try {
    let slackUser = await slack.users.lookupByEmail({ email: email });
    return slackUser.user?.id;
  } catch (error) {
    return undefined;
  }
}

export const handler: CodePipelineCloudWatchActionHandler = async (event, context, callback) => {
  try {
    const octokit = new Octokit({ auth: await getSSMParamValue(ssm, '/kms-opus-one-dev/LESSEN_GITHUB_TOKEN') });
    const slackWebhookUrl = await getSSMParamValue(ssm, '/kms-opus-one-dev/AWS_PIPELINE_ALERTS_SLACK_WEBHOOK_URL');
    const slack = new WebClient(await getSSMParamValue(ssm, '/kms-opus-one-dev/AWS_PIPELINE_ALERTS_SLACK_USER_TOKEN'));

    // Check if the event comes from a pipeline we care about
    let pipelineName = event.detail.pipeline;
    if (!pipelinesToMonitor.includes(pipelineName)) {
      callback(`Pipeline ${pipelineName} is not in the watch list. Ignoring.`);
      return;
    }

    console.log('Incoming event:');
    console.log(JSON.stringify(event));

    // Gather CodePipeline Action info
    let actionName = event.detail.action;
    let actionStage = event.detail.stage;
    let actionUrl = (event.detail as any)['execution-result']?.['external-execution-url'];
    let actionErrorSummary = (event.detail as any)['execution-result']?.['external-execution-summary'];
    let actionErrorCode = (event.detail as any)['execution-result']?.['error-code'];

    if (actionName === 'Prod_Approval') {
      callback(`Action name is ${pipelineName}. Ignoring.`);
      return;
    }

    // Find the git commit hash, message, and URL of the code that was deployed
    let pipelineExecutionId = event.detail['execution-id'];
    let pipelineExecution = await codePipeline
      .getPipelineExecution({
        pipelineExecutionId: pipelineExecutionId,
        pipelineName: pipelineName,
      })
      .promise();

    let builtCodeCommitHash = pipelineExecution.pipelineExecution?.artifactRevisions?.[0]?.revisionId;
    let builtCodeCommitMessage = pipelineExecution.pipelineExecution?.artifactRevisions?.[0]?.revisionSummary;
    let builtCodeCommitUrl = pipelineExecution.pipelineExecution?.artifactRevisions?.[0]?.revisionUrl;

    // Get commit info from e2e tests to add to the message if the Tests failed
    let includeE2eCommitInfo =
      (actionName === e2eTestActionNameByPipeline[pipelineName] && pipelineName === 'opus-one-cd-orchestration') ||
      (actionName === e2eTestActionNameByPipeline[pipelineName] && pipelineName === 'portal-cicd-pipeline');
    let e2eCommitInfo: string | undefined;

    if (includeE2eCommitInfo) {
      let e2eTestsCommit = await octokit.rest.repos.getCommit({
        owner: 'lessen-inc',
        repo: e2eTestRepoNameByPipeline[pipelineName],
        ref: 'HEAD',
      });

      let e2eGitCommitHash = e2eTestsCommit.data.sha;
      let e2eGitCommitMessage = e2eTestsCommit.data.commit.message;
      let e2eGitCommitUrl = e2eTestsCommit.data.url;

      let e2eUserEmail = e2eTestsCommit.data.commit.author?.email;
      let slackMemberId: string | undefined = '';
      if (e2eUserEmail) {
        slackMemberId = await tryGetSlackMemberIdByEmail(slack, e2eUserEmail);
        slackMemberId = slackMemberId ? `<@${slackMemberId}>` : '';
      }

      e2eCommitInfo = `

----------------------

*${e2eTestRepoNameByPipeline[pipelineName]} Commit Author Info*
    *GitHub name*: ${e2eTestsCommit.data.commit.author?.name || ''}
    *GitHub login*: ${e2eTestsCommit.data.author?.login || ''}
    *GitHub email*: ${e2eUserEmail || ''}
    *Slack*: ${slackMemberId}

*Commit Hash*:
    ${e2eGitCommitHash}

*Commit Message*:
\`\`\`${e2eGitCommitMessage}\`\`\`

<${e2eGitCommitUrl}|Link to commit>
`;
    }

    // Look up the author of that commit in github to get name, login, and email
    let builtCodeCommit = await octokit.rest.repos.getCommit({
      owner: 'lessen-inc',
      repo: repoNameByPipeline[pipelineName],
      ref: builtCodeCommitHash || '',
    });

    let builtCodeUserEmail = builtCodeCommit.data.commit.author?.email;
    let slackMemberId: string | undefined = '';
    if (builtCodeUserEmail) {
      slackMemberId = await tryGetSlackMemberIdByEmail(slack, builtCodeUserEmail);
      slackMemberId = slackMemberId ? `<@${slackMemberId}>` : '';
    }

    // Create slack message
    let slackWebhookPayload: object = {
      text: `
:alert: Action *${actionName}* failed in stage *${actionStage}* of pipeline *${pipelineName}*
    ${actionErrorCode}: ${actionErrorSummary}

<${actionUrl}|Link to Build logs>

*${repoNameByPipeline[pipelineName]} Commit Author Info*
    *GitHub name*: ${builtCodeCommit.data.commit.author?.name || ''}
    *GitHub login*: ${builtCodeCommit.data.author?.login || ''}
    *GitHub email*: ${builtCodeUserEmail || ''}
    *Slack*: ${slackMemberId}

*Commit Hash*:
    ${builtCodeCommitHash}

*Commit Message*:
\`\`\`${builtCodeCommitMessage}\`\`\`

<${builtCodeCommitUrl}|Link to commit>${includeE2eCommitInfo ? e2eCommitInfo : ''}
`,
    };

    console.log('Sending the following payload to Slack:');
    console.log(JSON.stringify(slackWebhookPayload));

    // Publish message to the Slack webhook
    await fetch(slackWebhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(slackWebhookPayload),
    });

    callback(null);
  } catch (error) {
    const slackWebhookUrl = await getSSMParamValue(ssm, '/kms-opus-one-dev/AWS_PIPELINE_ALERTS_SLACK_WEBHOOK_URL');
    let slackWebhookPayload: object = {
      text: `
*The AWS Pipeline Alerts lambda failed with the following error:*
<https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws$252Flambda$252Faws-pipeline-alerts-lambda|Link to lambda logs>
\`\`\`${error}\`\`\`
`,
    };

    console.log('Sending the following payload to Slack:');
    console.log(JSON.stringify(slackWebhookPayload));

    await fetch(slackWebhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(slackWebhookPayload),
    });
    throw error;
  }
};
