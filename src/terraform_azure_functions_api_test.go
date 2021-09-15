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
	http_helper.HttpGetWithRetry(t, url, nil, 200, "[]", 30, 5*time.Second)

	failurl := fmt.Sprintf("https://%s/api/news/this is a test", api_url)
	http_helper.HttpGetWithRetry(t, failurl, nil, 404, "", 30, 5*time.Second)	
}