data "archive_file" "lambda_catalog_updater_lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/catalog-updater"
  output_path = "${path.module}/zip/catalog-updater.zip"
}

data "archive_file" "lambda_backend_lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/backend"
  output_path = "${path.module}/zip/backend.zip"
}

data "archive_file" "lambda_cognito_pre_signup_trigger_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/cognito-pre-signup-trigger"
  output_path = "${path.module}/zip/cognito-pre-signup-trigger.zip"
}
data "archive_file" "lambda_cognito_post_confirmation_trigger_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/cognito-post-confirmation-trigger"
  output_path = "${path.module}/zip/cognito-post-confirmation-trigger.zip"
}
data "archive_file" "lambda_cognito_post_authentication_trigger_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/cognito-post-authentication-trigger"
  output_path = "${path.module}/zip/cognito-post-authentication-trigger.zip"
}
data "archive_file" "lambda_cognito_userpool_client_settings_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/cfn-cognito-user-pools-client-settings"
  output_path = "${path.module}/zip/cfn-cognito-user-pools-client-settings.zip"
}
data "archive_file" "lambda_cognito_userpool_domain_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/cfn-cognito-user-pools-domain"
  output_path = "${path.module}/zip/cfn-cognito-user-pools-domain.zip"
}
data "archive_file" "lambda_dump_v3_account_data_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/dump-v3-account-data"
  output_path = "${path.module}/zip/dump-v3-account-data.zip"
}
data "archive_file" "lambda_user_group_importer_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/user-group-importer"
  output_path = "${path.module}/zip/user-group-importer.zip"
}
data "archive_file" "lambda_cloudfront_security_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/cloudfront-security"
  output_path = "${path.module}/zip/cloudfront-security.zip"
}
data "archive_file" "lambda_security_header_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/security-header"
  output_path = "${path.module}/zip/security-header.zip"
}
data "archive_file" "lambda_api_key_authoriser_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/authoriser"
  output_path = "${path.module}/zip/authoriser.zip"
}
data "archive_file" "lambda_invoke_api_key_rotation_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/invoke-api-key-rotation"
  output_path = "${path.module}/zip/invoke-api-key-rotation.zip"
}
data "archive_file" "lambda_api_key_rotation_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/api-key-rotation"
  output_path = "${path.module}/zip/api-key-rotation.zip"
}

data "archive_file" "lambda_signin_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/signin"
  output_path = "${path.module}/zip/signin.zip"
}



data "archive_file" "lambda_get_catalog_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-catalog"
  output_path = "${path.module}/zip/get-catalog.zip"
}


data "archive_file" "lambda_get_apikey_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-apikey"
  output_path = "${path.module}/zip/get-apikey.zip"
}

data "archive_file" "lambda_get_subscription_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-subscription"
  output_path = "${path.module}/zip/get-subscription.zip"
}


data "archive_file" "lambda_update_subscription_usageplan_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/update-subscription-usageplan"
  output_path = "${path.module}/zip/update-subscription-usageplan.zip"
}

data "archive_file" "lambda_get_subscription_usageplan_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-subscription-usageplan"
  output_path = "${path.module}/zip/get-subscription-usageplan.zip"
}

data "archive_file" "lambda_delete_subscription_usageplan_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-subscription-usageplan"
  output_path = "${path.module}/zip/delete-subscription-usageplan.zip"
}

data "archive_file" "lambda_get_feedback_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-feedback"
  output_path = "${path.module}/zip/get-feedback.zip"
}

data "archive_file" "lambda_post_feedback_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/post-feedback"
  output_path = "${path.module}/zip/post-feedback.zip"
}

data "archive_file" "lambda_get_sdk_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-sdk"
  output_path = "${path.module}/zip/get-sdk.zip"
}

data "archive_file" "lambda_export_api_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/export-api"
  output_path = "${path.module}/zip/export-api.zip"
}

data "archive_file" "lambda_update_sdkgeneration_in_catalog_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/update-sdkgeneration-in-catalog"
  output_path = "${path.module}/zip/update-sdkgeneration-in-catalog.zip"
}

data "archive_file" "lambda_delete_sdkgeneration_from_catalog_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-sdkgeneration-from-catalog"
  output_path = "${path.module}/zip/delete-sdkgeneration-from-catalog.zip"
}


data "archive_file" "lambda_get_all_catalogs_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-all-catalogs"
  output_path = "${path.module}/zip/get-all-catalogs.zip"
}

data "archive_file" "lambda_add_new_api_to_catalog_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/update-catalog"
  output_path = "${path.module}/zip/update-catalog.zip"
}

data "archive_file" "lambda_delete_api_from_catalog_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-api-from-catalog"
  output_path = "${path.module}/zip/delete-api-from-catalog.zip"
}

data "archive_file" "lambda_get_all_accounts_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-accounts"
  output_path = "${path.module}/zip/get-accounts.zip"
}

data "archive_file" "lambda_create_new_account_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/create-new-account"
  output_path = "${path.module}/zip/create-new-account.zip"
}

data "archive_file" "lambda_get_specific_user_details_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-account-by-id"
  output_path = "${path.module}/zip/get-account-by-id.zip"
}

data "archive_file" "lambda_promote_user_to_admin_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/promote-user-to-admin"
  output_path = "${path.module}/zip/promote-user-to-admin.zip"
}

data "archive_file" "lambda_delete_user_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-account"
  output_path = "${path.module}/zip/delete-account.zip"
}

data "archive_file" "lambda_get_user_callbackauth_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-user-callbackauth"
  output_path = "${path.module}/zip/get-user-callbackauth.zip"
}


data "archive_file" "lambda_resend_invite_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/resend-invite"
  output_path = "${path.module}/zip/resend-invite.zip"
}

data "archive_file" "lambda_get_current_user_profile_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-current-user-profile"
  output_path = "${path.module}/zip/get-current-user-profile.zip"
}

data "archive_file" "lambda_update_user_profile_image_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/update-profile-image"
  output_path = "${path.module}/zip/update-profile-image.zip"
}

data "archive_file" "lambda_get_user_profile_image_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-profile-image"
  output_path = "${path.module}/zip/get-profile-image.zip"
}

data "archive_file" "lambda_create_mno_third_party_resources_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/create-mno-third-party-resources"
  output_path = "${path.module}/zip/create-mno-third-party-resources.zip"
}

data "archive_file" "lambda_get_mno_third_party_resources_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-mno-third-party-resources"
  output_path = "${path.module}/zip/get-mno-third-party-resources.zip"
}



data "archive_file" "lambda_create_permissions_for_api_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/create-permissions-for-api"
  output_path = "${path.module}/zip/create-permissions-for-api.zip"
}

data "archive_file" "lambda_get_allowed_apis_for_resource_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-allowed-apis-for-resource"
  output_path = "${path.module}/zip/get-allowed-apis-for-resource.zip"
}

data "archive_file" "lambda_delete_allowed_api_for_resource_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-allowed-apis-for-resource"
  output_path = "${path.module}/zip/delete-allowed-apis-for-resource.zip"
}

data "archive_file" "lambda_update_permissions_for_api_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/update-permissions-for-api"
  output_path = "${path.module}/zip/update-permissions-for-api.zip"
}

data "archive_file" "lambda_developer_portal_authoriser_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/developer-portal-authoriser"
  output_path = "${path.module}/zip/developer-portal-authoriser.zip"
}

data "archive_file" "lambda_get_mno_third_party_resource_by_id_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-mno-third-party-resources-by-id"
  output_path = "${path.module}/zip/get-mno-third-party-resources-by-id.zip"
}

data "archive_file" "lambda_get_mno_resource_users_account_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-mno-resource-users-accounts"
  output_path = "${path.module}/zip/get-mno-resource-users-accounts.zip"
}

data "archive_file" "lambda_get_third_party_resource_users_account_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-third-party-resource-users-accounts"
  output_path = "${path.module}/zip/get-third-party-resource-users-accounts.zip"
}

data "archive_file" "lambda_get_mno_resources_by_type_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-mno-resources-by-type"
  output_path = "${path.module}/zip/get-mno-resources-by-type.zip"
}

data "archive_file" "lambda_get_third_party_resources_by_type_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-third-party-resources-by-type"
  output_path = "${path.module}/zip/get-third-party-resources-by-type.zip"
}

data "archive_file" "lambda_get_third_party_user_by_id_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-third-party-user-by-id"
  output_path = "${path.module}/zip/get-third-party-user-by-id.zip"
}

data "archive_file" "lambda_get_mno_user_by_id_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-mno-user-by-id"
  output_path = "${path.module}/zip/get-mno-user-by-id.zip"
}


data "archive_file" "lambda_create_mno_resource_user_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/create-mno-resource-user"
  output_path = "${path.module}/zip/create-mno-resource-user.zip"
}

data "archive_file" "lambda_create_third_party_resource_user_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/create-third-party-resource-user"
  output_path = "${path.module}/zip/create-third-party-resource-user.zip"
}


data "archive_file" "lambda_delete_mno_resource_user_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-mno-resource-user"
  output_path = "${path.module}/zip/delete-mno-resource-user.zip"
}

data "archive_file" "lambda_delete_third_party_resource_user_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/delete-third-party-resource-user"
  output_path = "${path.module}/zip/delete-third-party-resource-user.zip"
}

data "archive_file" "lambda_update_user_account_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/update-user-account"
  output_path = "${path.module}/zip/update-user-account.zip"
}

data "archive_file" "lambda_get_all_apis_permissions_for_resource_function" {
  type        = "zip"
  source_dir  = "${path.module}/code/get-all-apis-permissions-for-resources"
  output_path = "${path.module}/zip/get-all-apis-permissions-for-resources.zip"
}
