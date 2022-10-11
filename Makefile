.PHONY: cloudformation
cloudformation:
	aws s3 cp templates/lambda.yaml s3://observeinc/cloudformation/lambda-`semtag final -s minor -o`.yaml

.PHONY: changelog
changelog:
	git-chglog -o CHANGELOG.md --next-tag `semtag final -s minor -o`

.PHONY: release
release: cloudformation
	semtag final -s minor