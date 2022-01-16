output "CATALOG_UPDATER_LAMBDA_ARN" {
  value = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
}
output "CATALOG_UPDATER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_catalog_updater_lambda_function.function_name
}

output "BACKEND_LAMBDA_ARN" {
  value = aws_lambda_function.lambda_backend_lambda_function.arn
}
output "BACKEND_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_backend_lambda_function.function_name
}
output "BACKEND_LAMBDA_INVOKE_ARN" {
  value = aws_lambda_function.lambda_backend_lambda_function.invoke_arn
}

output "COGNITO_PRESIGNUP_TRIGGER_LAMBDA_ARN" {
  value = aws_lambda_function.lambda_cognito_presignup_trigger_function.arn
}
output "COGNITO_PRESIGNUP_TRIGGER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_cognito_presignup_trigger_function.function_name
}

output "COGNITO_POST_AUTHENTICATION_TRIGGER_LAMBDA_ARN" {
  value = aws_lambda_function.lambda_cognito_post_authentication_trigger_function.arn
}
output "COGNITO_POST_AUTHENTICATION_TRIGGER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_cognito_post_authentication_trigger_function.function_name
}

output "COGNITO_POST_CONFIRMATION_TRIGGER_LAMBDA_ARN" {
  value = aws_lambda_function.lambda_cognito_post_confirmation_trigger_function.arn
}
output "COGNITO_POST_CONFIRMATION_TRIGGER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_cognito_post_confirmation_trigger_function.function_name
}
output "CLOUDFRONT_SECURITY_LAMBDA_ARN" {
  value = aws_lambda_function.lambda_cloudfront_security_function.arn
}
output "CLOUDFRONT_SECURITY_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_cloudfront_security_function.function_name
}
output "CLOUDFRONT_SECURITY_LAMBDA_QUALIFIED_ARN" {
  value = aws_lambda_function.lambda_cloudfront_security_function.qualified_arn
}
output "CLOUDFRONT_SECURITY_HEADER_ARN" {
  value = aws_lambda_function.lambda_cloudfront_security_function.arn
}
output "CLOUDFRONT_SECURITY_HEADER_NAME" {
  value = aws_lambda_function.lambda_cloudfront_security_function.function_name
}
output "CLOUDFRONT_SECURITY_HEADER_QUALIFIED_ARN" {
  value = aws_lambda_function.lambda_cloudfront_security_function.qualified_arn
}

output "API_KEY_AUTHORIZATION_LAMBDA_ARN" {
  value = "${aws_lambda_function.lambda_api_key_authoriser_function.arn}"
}
output "API_KEY_AUTHORIZATION_INVOKE_ARN" {
  value = "${aws_lambda_function.lambda_api_key_authoriser_function.invoke_arn}"
}
output "API_KEY_ROTATION_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_api_key_rotation.function_name
}
output "API_KEY_ROTATION_LAMBDA_INVOKE_ARN" {
  value = aws_lambda_function.lambda_api_key_rotation.arn
}
output "INVOKE_API_KEY_ROTATION_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_invoke_api_key_rotation.function_name
} 

output "LAMBDA_SIGNIN_INVOKE_ARN" {
  value = aws_lambda_function.lambda_signin_function.invoke_arn
}
output "SIGNIN_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_signin_function.function_name
}

output "LAMBDA_GET_APIKEY_INVOKE_ARN" {
  value = aws_lambda_function.lambda_get_apikey_function.invoke_arn
}
output "GET_APIKEY_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_get_apikey_function.function_name
}
output "LAMBDA_GET_CATALOG_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_catalog_function.invoke_arn
}
output "GET_CATALOG_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_catalog_function.function_name
}

output "LAMBDA_GET_SUBSCRIPTION_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_subscription_function.invoke_arn
}
output "GET_SUBSCRIPTION_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_subscription_function.function_name
}

output "LAMBDA_UPDATE_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN"{
  value = aws_lambda_function.lambda_update_subscription_usageplan_function.invoke_arn
}
output "UPDATE_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_update_subscription_usageplan_function.function_name
}

output "LAMBDA_DELETE_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN"{
  value = aws_lambda_function.lambda_delete_subscription_usageplan_function.invoke_arn
}
output "DELETE_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_delete_subscription_usageplan_function.function_name
}

output "LAMBDA_GET_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_subscription_usageplan_function.invoke_arn
}
output "GET_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_subscription_usageplan_function.function_name
}

output "LAMBDA_GET_FEEDBACK_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_feedback_function.invoke_arn
}
output "GET_FEEDBACK_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_feedback_function.function_name
}


output "LAMBDA_POST_FEEDBACK_INVOKE_ARN"{
  value = aws_lambda_function.lambda_post_feedback_function.invoke_arn
}
output "POST_FEEDBACK_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_post_feedback_function.function_name
}

output "LAMBDA_GET_SDK_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_sdk_function.invoke_arn
}
output "GET_SDK_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_sdk_function.function_name
}

output "LAMBDA_EXPORT_API_INVOKE_ARN"{
  value = aws_lambda_function.lambda_export_api_function.invoke_arn
}
output "EXPORT_API_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_export_api_function.function_name
}

output "LAMBDA_UPDATE_SDK_GENERATION_IN_CATALOG_API_INVOKE_ARN"{
  value = aws_lambda_function.lambda_update_sdkgeneration_in_catalog_function.invoke_arn
}
output "UPDATE_SDK_GENERATION_IN_CATALOG_API_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_update_sdkgeneration_in_catalog_function.function_name
}


output "LAMBDA_DELETE_SDK_GENERATION_IN_CATALOG_API_INVOKE_ARN"{
  value = aws_lambda_function.lambda_delete_sdkgeneration_from_catalog_function.invoke_arn
}
output "DELETE_SDK_GENERATION_IN_CATALOG_API_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_delete_sdkgeneration_from_catalog_function.function_name
}

output "LAMBDA_GET_ALL_CATALOGS_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_all_catalogs_function.invoke_arn
}
output "GET_ALL_CATALOGS_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_all_catalogs_function.function_name
}

output "LAMBDA_ADD_NEW_API_TO_CATALOGS_INVOKE_ARN"{
  value = aws_lambda_function.lambda_add_new_api_to_catalog_function.invoke_arn
}
output "ADD_NEW_API_TO_CATALOGS_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_add_new_api_to_catalog_function.function_name
}

output "LAMBDA_DELETE_API_FROM_CATALOGS_INVOKE_ARN"{
  value = aws_lambda_function.lambda_delete_api_from_catalog_function.invoke_arn
}
output "DELETE_API_FROM_CATALOGS_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_delete_api_from_catalog_function.function_name
}

output "LAMBDA_GET_ALL_ACCOUNTS_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_all_accounts_function.invoke_arn
}
output "GET_ALL_ACCOUNTS_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_all_accounts_function.function_name
}

output "LAMBDA_CREATE_NEW_ACCOUNT_INVOKE_ARN"{
  value = aws_lambda_function.lambda_create_new_account_function.invoke_arn
}
output "CREATE_NEW_ACCOUNT_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_create_new_account_function.function_name
}


output "LAMBDA_PROMOTE_USER_TO_ADMIN_INVOKE_ARN"{
  value = aws_lambda_function.lambda_promote_user_to_admin_function.invoke_arn
}
output "PROMOTE_USER_TO_ADMIN_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_promote_user_to_admin_function.function_name
}

output "LAMBDA_DELETE_USER_INVOKE_ARN"{
  value = aws_lambda_function.lambda_delete_user_function.invoke_arn
}
output "DELETE_USER_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_delete_user_function.function_name
}

output "LAMBDA_GET_USER_CALLBACKAUTH_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_user_callbackauth_function.invoke_arn
}
output "GET_USER_CALLBACKAUTH_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_user_callbackauth_function.function_name
}

output "LAMBDA_RESEND_INVITE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_resend_invite_function.invoke_arn
}
output "LAMBDA_RESEND_INVITE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_resend_invite_function.function_name
}


output "LAMBDA_GET_CURRENT_USER_PROFILE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_current_user_profile_function.invoke_arn
}
output "GET_CURRENT_USER_PROFILE_LAMBDA_NAME" {
   value = aws_lambda_function.lambda_get_current_user_profile_function.function_name
}


output "LAMBDA_UPDATE_USER_PROFILE_IMAGE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_update_user_profile_image_function.invoke_arn
}
output "UPDATE_USER_PROFILE_IMAGE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_update_user_profile_image_function.function_name
}

output "LAMBDA_GET_USER_PROFILE_IMAGE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_user_profile_image_function.invoke_arn
}
output "GET_USER_PROFILE_IMAGE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_user_profile_image_function.function_name
}


output "LAMBDA_CREATE_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_create_mno_third_party_resources_function.invoke_arn
}
output "CREATE_MNO_THIRD_PARTY_RESOURCE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_create_mno_third_party_resources_function.function_name
}



output "LAMBDA_CREATE_PERMISION_FOR_API_INVOKE_ARN"{
  value = aws_lambda_function.lambda_create_permissions_for_api_function.invoke_arn
}
output "CREATE_PERMISION_FOR_API_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_create_permissions_for_api_function.function_name
}



output "LAMBDA_GET_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_allowed_apis_for_resource_function.invoke_arn
}
output "GET_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_allowed_apis_for_resource_function.function_name
}

output "LAMBDA_DELETE_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_delete_allowed_api_for_resource_function.invoke_arn
}
output "DELETE_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_delete_allowed_api_for_resource_function.function_name
}

output "LAMBDA_GET_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_mno_third_party_resources_function.invoke_arn
}
output "GET_MNO_THIRD_PARTY_RESOURCE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_mno_third_party_resources_function.function_name
}

output "COGNITO_USERPOOL_CLIENT_SETTINGS_NAME" {
  value = aws_lambda_function.lambda_cognito_userpool_client_settings_function.function_name
}

output "API_KEY_AUTHORIZATION_LAMBDA_NAME" {
  value = "${aws_lambda_function.lambda_api_key_authoriser_function.function_name}"
}

output "DEVELOPER_PORTAL_AUTHORIZATION_INVOKE_ARN" {
  value = "${aws_lambda_function.lambda_developer_portal_authoriser_function.invoke_arn}"
}
output "DEVELOPER_PORTAL_AUTHORIZATION_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_developer_portal_authoriser_function.function_name
}


output "LAMBDA_GET_MNO_THIRD_PARTY_RESOURCE_BY_ID_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_mno_third_party_resources_by_id_function.invoke_arn
}
output "GET_MNO_THIRD_PARTY_RESOURCE_BY_ID_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_mno_third_party_resources_by_id_function.function_name
}

output "LAMBDA_GET_MNO_RESOURCE_BY_TYPE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_mno_resources_by_type_function.invoke_arn
}
output "GET_MNO_RESOURCE_BY_TYPE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_mno_resources_by_type_function.function_name
}

output "LAMBDA_GET_THIRD_PARTY_RESOURCE_BY_TYPE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_third_party_resources_by_type_function.invoke_arn
}
output "GET_THIRD_PARTY_RESOURCE_BY_TYPE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_third_party_resources_by_type_function.function_name
}


output "LAMBDA_GET_THIRD_PARTY_USER_BY_ID_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_third_party_user_by_id_function.invoke_arn
}
output "GET_THIRD_PARTY_USER_BY_ID_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_third_party_user_by_id_function.function_name
}

output "LAMBDA_GET_MNO_USER_BY_ID_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_mno_user_by_id_function.invoke_arn
}
output "GET_MNO_USER_BY_ID_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_mno_user_by_id_function.function_name
}

output "LAMBDA_GET_THIRD_PARTY_RESOURCES_USERS_ACCOUNTS_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_third_party_resource_users_account_function.invoke_arn
}
output "GET_THIRD_PARTY_RESOURCES_USERS_ACCOUNTS_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_third_party_resource_users_account_function.function_name
}



output "LAMBDA_GET_MNO_RESOURCES_USERS_ACCOUNTS_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_mno_resource_users_account_function.invoke_arn
}
output "GET_MNO_RESOURCES_USERS_ACCOUNTS_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_mno_resource_users_account_function.function_name
}

output "LAMBDA_THIRD_PARTY_RESOURCE_USER_INVOKE_ARN" {
  value = aws_lambda_function.lambda_create_third_party_resource_user_function.invoke_arn
}

output "CREATE_THIRD_PARTY_RESOURCE_USER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_create_third_party_resource_user_function.function_name
}

output "LAMBDA_DELETE_THIRD_PARTY_RESOURCE_USER_INVOKE_ARN" {
  value = aws_lambda_function.lambda_delete_mno_resource_user_function.invoke_arn
}

output "DELETE_THIRD_PARTY_RESOURCE_USER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_delete_mno_resource_user_function.function_name
}

output "LAMBDA_DELETE_MNO_RESOURCE_USER_INVOKE_ARN" {
  value = aws_lambda_function.lambda_delete_mno_resource_user_function.invoke_arn
}

output "DELETE_MNO_RESOURCE_USER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_delete_mno_resource_user_function.function_name
}

output "CREATE_MNO_RESOURCE_USER_LAMBDA_NAME" {
  value = aws_lambda_function.lambda_create_mno_resource_user_function.function_name
}
output "LAMBDA_MNO_RESOURCE_USER_INVOKE_ARN" {
  value = aws_lambda_function.lambda_create_third_party_resource_user_function.invoke_arn
}

output "LAMBDA_UPDATE_PERMISION_FOR_API_INVOKE_ARN"{
  value = aws_lambda_function.lambda_update_allowed_api_for_resource_function.invoke_arn
}
output "UPDATE_PERMISION_FOR_API_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_update_allowed_api_for_resource_function.function_name
}

output "LAMBDA_UPDATE_USER_ACCOUNT_INVOKE_ARN"{
  value = aws_lambda_function.lambda_update_user_account_function.invoke_arn

}
output "UPDATE_USER_ACCOUNT_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_update_user_account_function.function_name

}

output "LAMBDA_GET_ALL_APIS_FOR_RESOURCE_INVOKE_ARN"{
  value = aws_lambda_function.lambda_get_all_apis_for_resource_function.invoke_arn

}
output "GET_ALL_APIS_FOR_RESOURCE_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_get_all_apis_for_resource_function.function_name

}

output "LAMBDA_GENERATE_NEW_API_KEY_INVOKE_ARN"{
  value = aws_lambda_function.lambda_generate_new_api_key.invoke_arn

}
output "GENERATE_NEW_API_KEY_LAMBDA_NAME"{
  value = aws_lambda_function.lambda_generate_new_api_key.function_name

}
