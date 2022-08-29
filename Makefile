LOCAL_ENV_FILE=.env.local
include ${LOCAL_ENV_FILE}

FUNCTION_ENTRYPOINT=mpz-feedback
NAME=mpz-feedback
GOOGLE_CLOUD_PROJECT=random-360814
REGION=us-central1
INVOKE_URL=https://$(REGION)-$(GOOGLE_CLOUD_PROJECT).cloudfunctions.net/$(NAME)

ENV_VARS=$(shell ruby -e "print File.readlines('${LOCAL_ENV_FILE}').map { |l| l.gsub('export ', '').strip }.join(',')")

all: local_server

deploy:
	gcloud --project=$(GOOGLE_CLOUD_PROJECT) functions deploy $(NAME) --entry-point $(FUNCTION_ENTRYPOINT) --max-instances 1 --set-env-vars=$(ENV_VARS) --trigger-http --runtime ruby30 --memory=128M --timeout=20 --region $(REGION) --allow-unauthenticated
	@echo $(INVOKE_URL)

undeploy:
	gcloud --project=$(GOOGLE_CLOUD_PROJECT) functions delete $(NAME) --quiet

local_server:
	bundle exec functions-framework-ruby --target=$(FUNCTION_ENTRYPOINT) --port=3001 --detailed-errors --verbose

test_local:
	curl -X POST http://localhost:3001 -H "Content-Type: application/json" --data '{"text": "Test text", "author": "TestUser", "sysinfo": "TestSysinfo"}'

test_production:
	curl -X POST $(INVOKE_URL) -H "Content-Type: application/json" --data '{"text": "Test text", "author": "TestUser", "sysinfo": "TestSysinfo"}'

.PHONY: deploy undeploy local_server test_local test_production
