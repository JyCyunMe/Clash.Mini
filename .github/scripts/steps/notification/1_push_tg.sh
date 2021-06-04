# 推送到TG

##pip install requests BeautifulSoup4
##touch ./.github/output/release_log
##python3 ./.github/scripts/steps/notification/release_text.py || {
##  echo -e "\n run release_text.py failed."
##  exit 1
##}
RLT=$(curl --location --request POST https://api.telegram.org/bot${TG_TOKEN}/sendMessage -s --form-string chat_id=${CHAT_ID} --form-string text="$(perl -lne 'print;' ./RELEASELOG.md)" --form-string parse_mode="Markdown" --form-string disable_web_page_preview="true" --form-string allow_sending_without_reply="true" --form-string reply_markup="{\"inline_keyboard\":[[{\"text\":\"Download\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini/releases/tag/${GIT_TAG}\"},{\"text\":\"GitHub\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini\"}]]}")
IS_OK=$(echo $RLT | jq ".ok")
if [ $IS_OK ]; then
  MSG_ID=$(echo $RLT | jq ".result.message_id")
  DT_STR=$(date "+%Y%m%d%H%M%S")
  PART_X64=$(echo "${DT_STR}_Clash.Mini_X64" | base64 | tr -s "=" 2)
  PART_X86=$(echo "${DT_STR}_Clash.Mini_X86" | base64 | tr -s "=" 2)

  RELEASE_URL="https://github.com/JyCyunMe/Clash.Mini/releases/download/${GIT_TAG}"
  echo $RELEASE_URL
  RELEASE_PATH="$(pwd)/releases"
  mkdir -p $RELEASE_PATH
  echo "${RELEASE_URL}/${RELEASE_PKG_X64}"
  echo "${RELEASE_URL}/${RELEASE_PKG_X86}"
  echo "${RELEASE_URL}/${RELEASE_PKG_X64}.sha256"
  echo "${RELEASE_URL}/${RELEASE_PKG_X86}.sha256"
  curl -L -o "${RELEASE_PATH}/${RELEASE_PKG_X64}" "${RELEASE_URL}/${RELEASE_PKG_X64}"
  curl -L -o "${RELEASE_PATH}/${RELEASE_PKG_X86}" "${RELEASE_URL}/${RELEASE_PKG_X86}"
  curl -L -o "${RELEASE_PATH}/${RELEASE_PKG_X64}.sha256" "${RELEASE_URL}/${RELEASE_PKG_X64}.sha256"
  curl -L -o "${RELEASE_PATH}/${RELEASE_PKG_X86}.sha256" "${RELEASE_URL}/${RELEASE_PKG_X86}.sha256"
  ls -lah $RELEASE_PATH

  RELEASE_SHA256_X64=$(cat "${RELEASE_PATH}/${RELEASE_PKG_X64}.sha256" | tr -d "\n")
  RELEASE_SHA256_X86=$(cat "${RELEASE_PATH}/${RELEASE_PKG_X86}.sha256" | tr -d "\n")
  RLT=$(curl --location --request POST https://api.telegram.org/bot${TG_TOKEN}/sendMediaGroup -s --form-string chat_id=${CHAT_ID} --form-string reply_to_message_id=$MSG_ID --form $PART_X64=@"${RELEASE_PATH}/${RELEASE_PKG_X64}" --form $PART_X86=@"${RELEASE_PATH}/${RELEASE_PKG_X86}" --form-string media="[{\"type\": \"document\",\"media\": \"attach://$PART_X64\",\"caption\": \"SHA256: ${RELEASE_SHA256_X64}\",\"parse_mode\": \"Markdown\"},{\"type\": \"document\",\"media\": \"attach://$PART_X86\",\"caption\": \"SHA256: ${RELEASE_SHA256_X64}\",\"parse_mode\": \"Markdown\"}]")
  IS_OK=$(echo $RLT | jq ".ok")
  if [ ! $IS_OK ]; then
    echo "Reply files to channel failed. Response: "
    echo $RLT | jq .
    exit 1
  fi
else
  echo "push to channel failed. Response: "
  echo $RLT | jq .
  exit 1
fi
