# 推送到TG

if [ $ENABLE_PUSH_FILES ]; then
  DT_STR=$(date "+%Y%m%d%H%M%S")
  PART_X64=$(echo "${DT_STR}_Clash.Mini_X64_${GITHUB_SHA}" | base64 | tr -s "=" 2)
  PART_X86=$(echo "${DT_STR}_Clash.Mini_X86_${GITHUB_SHA}" | base64 | tr -s "=" 2)

  RUNNER_URL="https://github.com/JyCyunMe/Clash.Mini/actions/runs/${GITHUB_RUN_ID}"
  echo "$RUNNER_URL"
  ls -lah "$ARTIFACTS_PATH"

  ARTIFACT_X64_SHA256=$(cat "${ARTIFACTS_PATH}/${BUILD_X64_FILENAME}.sha256" | tr -d "\n")
  ARTIFACT_X86_SHA256=$(cat "${ARTIFACTS_PATH}/${BUILD_X64_FILENAME}.sha256" | tr -d "\n")
  RLT=$(curl --location --request POST https://api.telegram.org/bot${TG_TOKEN}/sendMediaGroup -s --form-string chat_id=${UPLOAD_CHAT_ID} --form $PART_X64=@"${ARTIFACTS_PATH}/${BUILD_X64_FILENAME}" --form $PART_X86=@"${ARTIFACTS_PATH}/${BUILD_X86_FILENAME}" --form-string media="[{\"type\": \"document\",\"media\": \"attach://$PART_X64\",\"caption\": \"SHA256: ${ARTIFACT_X64_SHA256}\n\n_[${GITHUB_WORKFLOW} #${GITHUB_RUN_NUMBER}](${RUNNER_URL})_\",\"parse_mode\": \"Markdown\"},{\"type\": \"document\",\"media\": \"attach://$PART_X86\",\"caption\": \"SHA256: ${ARTIFACT_X86_SHA256}\n\n_[${GITHUB_WORKFLOW} #${GITHUB_RUN_NUMBER}](${RUNNER_URL})_\",\"parse_mode\": \"Markdown\"}]")
  IS_OK=$(echo $RLT | jq ".ok")
  echo $RLT | jq .
  if [ ! $IS_OK ]; then
    echo "pushing files to channel failed. Response: "
    echo $RLT | jq .
    exit 1
  fi
else
  echo "pushing files is disabled"
fi
