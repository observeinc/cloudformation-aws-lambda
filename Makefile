S3_CP_ARGS=aws s3 cp --acl public-read
S3_PREFIX=s3://observeinc/cloudformation
PUBLIC_URL=https://observeinc.s3.amazonaws.com/cloudformation
RELEASE_AWS_ACCOUNT=723346149663

.PHONY: preflight
preflight:
	@test "`aws sts get-caller-identity --query Account --output text`" = "$(RELEASE_AWS_ACCOUNT)" || \
		{ echo "AWS credentials must be for account $(RELEASE_AWS_ACCOUNT) (check AWS_PROFILE)"; exit 1; }
	@test "`git rev-parse --abbrev-ref HEAD`" = "main" || { echo "Releases must be cut from main"; exit 1; }
	@git diff --quiet HEAD -- || { echo "Working tree has uncommitted changes"; exit 1; }
	@git fetch -q origin main
	@test "`git rev-parse HEAD`" = "`git rev-parse origin/main`" || { echo "Local main is not in sync with origin/main"; exit 1; }

.PHONY: cloudformation
cloudformation:
	$(S3_CP_ARGS) templates/lambda.yaml $(S3_PREFIX)/lambda-`semtag final -s minor -o`.yaml
	$(S3_CP_ARGS) templates/lambda.yaml $(S3_PREFIX)/lambda-latest.yaml

.PHONY: changelog
changelog:
	git-chglog -o CHANGELOG.md --next-tag `semtag final -s minor -o`

.PHONY: release
release: preflight cloudformation
	semtag final -s minor

# Confirm the published templates match the template at the latest tag.
.PHONY: verify
verify:
	@VERSION=`git describe --tags --abbrev=0`; \
	EXPECTED=`git show $$VERSION:templates/lambda.yaml | shasum -a 256 | cut -d' ' -f1`; \
	for f in $$VERSION latest; do \
		ACTUAL=`curl -sf $(PUBLIC_URL)/lambda-$$f.yaml | shasum -a 256 | cut -d' ' -f1`; \
		if [ "$$ACTUAL" = "$$EXPECTED" ]; then echo "OK   lambda-$$f.yaml"; \
		else echo "FAIL lambda-$$f.yaml does not match $$VERSION"; exit 1; fi; \
	done
