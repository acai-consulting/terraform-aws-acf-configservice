package test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExampleComplete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")

	terraformCentral := &terraform.Options{
		TerraformDir: "../examples/central",
		NoColor:      false,
		Lock:         true,
		// Specify a unique state file for the 'central' environment
		BackendConfig: map[string]interface{}{
			"key": "central.tfstate",  // Use a unique state file name
		},
	}

	terraformMember := &terraform.Options{
		TerraformDir: "../examples/member-provisio",
		NoColor:      false,
		Lock:         true,
		// Specify a unique state file for the 'central' environment
		BackendConfig: map[string]interface{}{
			"key": "member.tfstate",  // Use a unique state file name
		},
	}

	defer terraform.Destroy(t, terraformCentral)
	
	terraform.InitAndApply(t, terraformCentral)
	terraform.InitAndApply(t, terraformMember)

	// Retrieve the 'test_success' output
	testSuccessOutput := terraform.Output(t, terraformMember, "test_success")

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")

	terraform.Destroy(t, terraformMember)
}
