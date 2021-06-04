# 推送到TG

#pip install requests BeautifulSoup4
#touch ./.github/output/release_log
#python3 ./.github/scripts/steps/notification/release_text.py || {
#  echo -e "\n run release_text.py failed."
#  exit 1
#}
#RLT=$(curl --location --request POST https://api.telegram.org/bot${{ seN  }}/sendMessage -s --form-string chat_id=${{t-id }} --form-string text="$(perl -lne 'print;' ./RELEASELOG.md)" --form-string parse_mode="Markdown" --form-string disable_web_page_preview="true" --form-string allow_sending_without_reply="true" --form-string reply_markup="{\"inline_keyboard\":[[{\"text\":\"Download\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini/releases/tag/${{ needs.build-release-windows.outputs.git-tag }}\"},{\"text\":\"GitHub\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini\"}]]}")
RLT=$(curl --location --request POST https://api.telegram.org/bot${TG_TOKEN}/sendMessage -s --form-string chat_id=${CHAT_ID} --form-string text="$(perl -lne 'print;' ./RELEASELOG.md)" --form-string parse_mode="Markdown" --form-string disable_web_page_preview="true" --form-string allow_sending_without_reply="true" --form-string reply_markup="{\"inline_keyboard\":[[{\"text\":\"Download\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini/releases/tag/${GIT_TAG}\"},{\"text\":\"GitHub\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini\"}]]}")
#RLT=$(curl --location --request POST https://api.telegram.org/bot${TG_TOKEN}/sendMessage -s --form-string chat_id=${CHAT_ID} --form-string text="$(perl -lne 'print;' ./RELEASELOG.md)" --form-string parse_mode="Markdown" --form-string disable_web_page_preview="true" --form-string allow_sending_without_reply="true" --form-string reply_markup="{\"inline_keyboard\":[[{\"text\":\"Download\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini/releases/tag/${GIT_TAG}\"},{\"text\":\"GitHub\",\"url\":\"https://github.com/JyCyunMe/Clash.Mini\"}]]}")

if [[ -e $(echo $RLT | jq ".ok") ]]; then
    MSG_ID=$(echo $RLT | jq ".result.message_id")
    DT_STR=$(date "+%Y%m%d%H%M%S")
    PART_X64=$(echo "${DT_STR}_Clash.Mini_X64" | base64 | tr -s "=" 2)
    PART_X86=$(echo "${DT_STR}_Clash.Mini_X86" | base64 | tr -s "=" 2)

    RELEASE_PATH=RELEASE_PATH
    RELEASE_PATH=$(echo ${RELEASE_PATH//:/})
    RELEASE_PATH=$(echo ${RELEASE_PATH//\\//})
else
    echo "push to channel failed. Response: "
    echo $RLT | jq .
    exit 1
fi
