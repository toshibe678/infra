import * as cdk from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import {CdkStack} from '../lib/cdk-stack';
import {RootStack} from '../lib/root-stack';
import {SandboxStack} from '../lib/sandbox-stack';
import {BlogStack} from '../lib/blog-stack';


// test("cdk stack test snapshot", () => {
//   const app = new cdk.App();
//   const stack = new CdkStack(app, "CdkStack");
//   const template = Template.fromStack(stack);
//   expect(template.toJSON()).toMatchSnapshot();
// });
//
// test("root stack test snapshot", () => {
//   const app = new cdk.App();
//   const stack = new RootStack(app, "RootStack");
//   const template = Template.fromStack(stack);
//   expect(template.toJSON()).toMatchSnapshot();
// });
//
// test("sandbox stack test snapshot", () => {
//   const app = new cdk.App();
//   const stack = new SandboxStack(app, "SandboxStack");
//   const template = Template.fromStack(stack);
//   expect(template.toJSON()).toMatchSnapshot();
// });
//
// test("blog stack test snapshot", () => {
//   const app = new cdk.App();
//   const stack = new BlogStack(app, "BlogStack");
//   const template = Template.fromStack(stack);
//   expect(template.toJSON()).toMatchSnapshot();
// });
