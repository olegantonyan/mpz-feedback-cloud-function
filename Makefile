LOCAL_ENV_FILE=.env.local
include ${LOCAL_ENV_FILE}

FUNCTION_ENTRYPOINT=mpz-feedback
NAME=mpz-feedback
GOOGLE_CLOUD_PROJECT=random-360814
INVOKE_URL=https://us-central1-$(GOOGLE_CLOUD_PROJECT).cloudfunctions.net/$(NAME)

ENV_VARS=$(shell ruby -e "print '--set-env-vars=' + File.readlines('${LOCAL_ENV_FILE}').map { |l| l.gsub('export ', '').strip }.join(',')")

all: local_server

deploy:
	gcloud --project=$(GOOGLE_CLOUD_PROJECT) functions deploy $(NAME) --entry-point $(FUNCTION_ENTRYPOINT) --max-instances 1 $(ENV_VARS) --trigger-http --runtime ruby30
	@echo $(INVOKE_URL)

undeploy:
	gcloud --project=$(GOOGLE_CLOUD_PROJECT) functions delete $(NAME) --quiet

local_server:
	bundle exec functions-framework-ruby --target=$(FUNCTION_ENTRYPOINT) --port=3001 --detailed-errors --verbose

test_production:
	curl -X POST $(INVOKE_URL) -H "Content-Type: application/json" --data '{"text": "Test text", "author": "TestUser", "sysinfo": "TestSysinfo"}'
