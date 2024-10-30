#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { RootStack } from '../lib/root-stack';
import { SandboxStack } from '../lib/sandbox-stack';
import { BlogStack } from '../lib/blog-stack';
import { CdkStack } from '../lib/cdk-stack';

const app = new cdk.App();

new CdkStack(app, 'CdkStack', {
  /*  information, see https://docs.aws.amazon.com/cdk/latest/guide/environments.html */
});

new RootStack(app, 'RootStack', {
  env: { account: '814229680634', region: 'ap-northeast-1' },
});

new SandboxStack(app, 'SandboxStack', {
  env: { account: '570339075110', region: 'ap-northeast-1' },
});

new BlogStack(app, 'BlogStack', {
  env: { account: '073855610728', region: 'ap-northeast-1' },
});
