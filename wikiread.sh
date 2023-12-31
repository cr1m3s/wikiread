#!/usr/bin/env bash

LANGUAGE="en"
DOCPATH="$HOME/Documents/wikiread/"

main() {
	if [ ! -d $DOCPATH ]; then
		mkdir $DOCPATH && green_style "Folder $DOCPATH created"
	fi
	orange_style "Results stored in $DOCPATH"
	pink_style "Select one option or press Ctrl+C to exit"
	
	options=("Search" "Language" "Clean")

  while true; do
    option=$(gum choose ${options[*]})

    case $option in

    "Search")
      $(search)
      ;;

    "Language")
      change_language
      ;;

    "Clean")
      clean
      ;;

    *)
      exit 0
      ;;
    esac
  done
}

green_style() {
	gum style --border=rounded --align center --width 50 --foreground "#008000" --border-foreground "#008000" -- "$1"
}

pink_style() {
	gum style --border=rounded --align center --width 50 --foreground 212 --border-foreground 212 -- "$1"
}

orange_style() {
	gum style --border rounded --align center --width 50 --foreground "#FF7F50" --border-foreground "#FF7F50" -- "$1"
}


change_language() {
  languages=("en" "simple" "fr")
  LANGUAGE=$(gum choose ${languages[*]})
}

clean() {
  rm $DOCPATH/*.pdf 2>/dev/null
}

search() {
  while true; do
    title=$(gum input --placeholder "Enter wiki page name or Ctrl+C to exit")

    if [ $? -ne 0 ]; then
      exit 0
    fi

    search=$(gum spin --title "looking for ${title}" --show-output -- curl -s "https://${LANGUAGE}.wikipedia.org/w/api.php?action=opensearch&format=json&search=${title}" | jq -r)

    declare -a links=()
    for item in ${search[*]}; do
      tmp=$(echo ${item} | grep "https" | cut -d "/" -f 5 | tr -d "," | tr -d "\"")
      links+=(${tmp})
    done

    if [ ${#links[@]} -gt 0 ]; then
      page=$(gum choose ${links[*]})
      gum spin --title "loading $page page" --show-output -- curl -s "https://${LANGUAGE}.wikipedia.org/api/rest_v1/page/pdf/${page}" >$DOCPATH/${page}.pdf
      zathura $DOCPATH/${page}.pdf &
    else
      echo "Nothing was found"
    fi

  done
}

main
