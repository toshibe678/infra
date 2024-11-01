import * as cdk from 'aws-cdk-lib';
import * as iam from 'aws-cdk-lib/aws-iam';
import {Construct} from 'constructs';
import {Duration} from "aws-cdk-lib";

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Github Actions からの接続用OIDCプロバイダーを作成
    const idProvider = new iam.OpenIdConnectProvider(this, 'IDProvider', {
      url: 'https://token.actions.githubusercontent.com',
      clientIds: ['sts.amazonaws.com'],
    });
    // GitHub Actions からの接続用ロールを作成
    const role = new iam.Role(this, 'Role', {
      roleName: 'GitHubActionsRole',
      maxSessionDuration: Duration.hours(2),
      assumedBy: new iam.WebIdentityPrincipal(idProvider.openIdConnectProviderArn, {
        StringEquals: {
          ['token.actions.githubusercontent.com:aud']: 'sts.amazonaws.com',
        },
        StringLike: {
          ['token.actions.githubusercontent.com:sub']: 'repo:toshibe678/*:*',
        },
      }),
    });
    role.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('AdministratorAccess'));
  }
}
