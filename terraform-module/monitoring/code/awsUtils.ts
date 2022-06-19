import * as AWS from 'aws-sdk';

export async function getSSMParamValue(ssm: AWS.SSM, paramName: string): Promise<string> {
  const parameter = await ssm
    .getParameter({
      Name: paramName,
      WithDecryption: true,
    })
    .promise();

  if (!parameter.Parameter?.Value) {
    throw new Error(`Failed to get value for parameter ${paramName}`);
  }

  return parameter.Parameter.Value;
}
