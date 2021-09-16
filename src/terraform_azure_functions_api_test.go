package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAzureFunctionsAPIReachable(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./infra",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	api_url := terraform.Output(t, terraformOptions, "api_url")

	url := fmt.Sprintf("https://%s/api/news", api_url)
	http_helper.HttpGetWithRetry(t, url, nil, 200, "[]", 30, 5*time.Second) //As we've just initialized the environment, calling the url with all the news should result in an empty response body.

	failurl := fmt.Sprintf("https://%s/api/news/this is a test", api_url)
	http_helper.HttpGetWithRetry(t, failurl, nil, 404, "", 30, 5*time.Second) //By the same logic, retrieving a specific title "this is a test" should result in a 404 being returned.

	posturl := fmt.Sprintf("https://%s/api/newsitem", api_url)
	body := []byte("{\"Title\": \"This is a test.\", \"Description\": \"It's for testing!\"}")
	headers := map[string]string{}
	http_helper.HTTPDoWithValidationRetry(t, "POST", posturl, body, headers, 200, "Your article with title 'This is a test.' was saved successfully.", 30, 5*time.Second, nil)
}
