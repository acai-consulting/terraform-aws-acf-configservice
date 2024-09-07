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
	}

	defer terraform.Destroy(t, terraformCentral)
	terraform.InitAndApply(t, terraformCentral)

	terraformMember := &terraform.Options{
		TerraformDir: "../examples/member-provisio",
		NoColor:      false,
		Lock:         true,
	}

	defer terraform.Destroy(t, terraformMember)
	terraform.InitAndApply(t, terraformMember)

	// Retrieve the 'test_success' output
	testSuccessOutput := terraform.Output(t, terraformReadConfiguration, "test_success")

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
}
