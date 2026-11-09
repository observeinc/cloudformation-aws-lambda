# AWS Lambda Cloudformation Template

CloudFormation template which sets up a Lambda to forward event data towards Observe.

## Usage

When creating a CloudFormation stack, set the S3 URL to [`https://observeinc.s3-us-west-2.amazonaws.com/cloudformation/lambda-latest.yaml`](https://observeinc.s3-us-west-2.amazonaws.com/cloudformation/lambda-latest.yaml).

For pinned template versions, see [the Observe Lambda CF template change log](https://github.com/observeinc/cloudformation-aws-lambda/blob/main/CHANGELOG.md) in GitHub.

## Releasing

A release has two parts: a CHANGELOG commit and `make release`. The CHANGELOG commit alone does not publish anything — the template is only available once `make release` uploads it to S3 and pushes the tag.

Requirements: [`semtag`](https://github.com/nico2sh/semtag), [`git-chglog`](https://github.com/git-chglog/git-chglog), and the AWS CLI.

1. Merge your change to `main`.
2. Run `make changelog`, then commit and merge the updated `CHANGELOG.md` via a PR.
3. Check out `main` and pull, so it matches `origin/main`.
4. Get AWS credentials for account `723346149663` (Britive `BritiveEng-EngDev`). If `AWS_PROFILE` is set in your shell, make sure it points at that account.
5. Run `make release`. This:
   - checks the AWS account and that `main` is clean and in sync (`make preflight`)
   - uploads `templates/lambda.yaml` to `s3://observeinc/cloudformation/lambda-vX.Y.Z.yaml` and `lambda-latest.yaml`
   - creates and pushes the `vX.Y.Z` tag

   If the upload fails, no tag is created.
6. Run `make verify` to confirm both published templates match the tagged template.
7. Optionally create a GitHub release: `gh release create vX.Y.Z --notes-from-tag`.
8. If the change affects customers, ask the docs team to update the pinned version example on the [Observe Lambda docs page](https://docs.observeinc.com/docs/observe-lambda).

Note that published file names include the `v` prefix (e.g. `lambda-v0.4.0.yaml`).