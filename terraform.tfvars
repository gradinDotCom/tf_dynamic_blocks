filters = {
    string_in = {
      "data.blobType" = ["BlockBlob"]
    },
    string_begins_with = {
        "data.url" = ["https://myaccount.blob.core.windows.net"]
    }
}

adv_block = [1]