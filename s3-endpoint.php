<?php
function tw_s3_uploads_s3_client_params( $params ) {
    if (S3_PROVISIONNER == "ceph") {
        $params["endpoint"] = S3_UPLOADS_ENDPOINT;
        $params["use_path_style_endpoint"] = true;
        return $params;
    } else {
        return $params;
    }
}

add_filter( "s3_uploads_s3_client_params", "tw_s3_uploads_s3_client_params");
