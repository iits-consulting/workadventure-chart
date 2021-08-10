#!/bin/bash

function usage(){

  echo "This script replaces variables in slack messages json templates."
  echo ""
  echo -e "\t-h --help"
  echo -e "\t--type=<Type of event (success, failed or aborted)>"
  echo -e "\t--chart-name=<Helm chart name>"
  echo -e "\t--chart-version=<Helm chart version>"
  echo -e "\t--chart-link=<Link to the chart repository>"
  echo -e "\t--action-link=<Link to exact GitHub Action output>"
}

function replace() {
  sed -e "s/REPLACEME_CHART_NAME/${CHART_NAME}/" ${TEMPLATE_FILE}
  sed -e "s/REPLACEME_CHART_VERSION/${CHART_VERSION}/" ${TEMPLATE_FILE}
  sed -e "s/REPLACEME_REPO_LINK/${CHART_LINK}/" ${TEMPLATE_FILE}
  sed -e "s/REPLACEME_GITHUB_ACTION_LINK/${ACTION_LINK}/" ${TEMPLATE_FILE}

  echo SLACK_MESSAGE_SUCCESS=$(jq -c . successed_slack_message.json | sed 's/"/\\"/g') >> $GITHUB_ENV
  echo SLACK_MESSAGE_FAILURE=$(jq -c . failed_slack_message.json | sed 's/"/\\"/g') >> $GITHUB_ENV
  echo SLACK_MESSAGE_ABORT=$(jq -c . aborted_slack_message.json | sed 's/"/\\"/g') >> $GITHUB_ENV
}

function select_file() {
  case ${TYPE} in
    success
      TEMPLATE_FILE="successed_slack_message.json"
    failed
      TEMPLATE_FILE="failed_slack_message.json"
    aborted
      TEMPLATE_FILE="aborted_slack_message.json"
  esac
}

function main(){
  while [[ "$1" != "" ]]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case ${PARAM} in
      -h | --help)
          usage
          ;;
      -t | --type)
          TYPE=${VALUE}
          ;;
      --chart-name)
          CHART_NAME=${VALUE}
          ;;
      --chart-version)
          CHART_VERSION=${VALUE}
          ;;
      --chart-link)
          CHART_LINK=${VALUE}
          ;;
      --action-link)
          ACTION_LINK=${VALUE}
          ;;
          esac
          ;;
      *)
        log_error "Unknown parameter ${PARAM}"
        usage
        exit 1
        ;;
    esac
    shift
  done
  replace
}

main "$@"

