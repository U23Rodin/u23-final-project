{
    "Version": "2012-10-17",  // Version of the policy language, NOT of the template file!
    "Statement": [ // Array of policy statements
        {
            "Effect": "Allow",  // This statement allows the specified action
            "Principal": {
                "Federated": "${oidc_provider_arn}"  // Specifies the federated identity (OpenID Connect provider) that is allowed to assume the role. In this case the EKS oidc
            },
            "Action": "sts:AssumeRoleWithWebIdentity",  // The action that is allowed, assuming a role with a web identity
            "Condition": {  // Conditions that must be met for the policy to apply
                "StringEquals": {
                    "${oidc_provider_url}:aud": "sts.amazonaws.com",  // The audience (aud) claim must match 'sts.amazonaws.com'
                    "${oidc_provider_url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"    // The subject (sub) claim must match the specified service account in the Kubernetes system namespace
                }
            }
        }
    ]
}
