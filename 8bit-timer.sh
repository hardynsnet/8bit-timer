#!/usr/bin/env bash
#
# 8bit-timer.sh -- Temporizador retro estilo 8-bit pata la terminal
#
# Autor: hardynsnet
# Licencia: MIT
#
# Uso:
#	./8bit-timer.sh 25m 	# 25 minutos
#	./8bit-timer.sh 90 	# 90 segundos
#	./8bit-timer.sh 1:30	# 1 minuto 30 segundos
#	./8bit-timer.sh		# modo interactivo (pregunta la duración)
#
set -euo pipefail

# ------------------------------------------------------------------
# Colores ANSI (paleta estilo consola retro de 8 bits)
# ------------------------------------------------------------------
RESET='\033[0m'
BOLD='\033[1m'
PALETTE=(
	'\033[38;5;196m' # ROJO
	'\033[38;5;208m' # NARANJA
	'\033[38;5;226m' # AMARILLO
	'\033[38;5;46m' # VERDE
	'\033[38;5;51m' # CIAN
	'\033[38;5;93m' # MORADO
	'\033[38;5;201m' # MAGENTA
)
COLOR_COUNT=${#PALETTE[@]}

# ------------------------------------------------------------------
# Glifos 8-bit (bloques 5x5) para dígitos 0-9 y separador ":"
# ------------------------------------------------------------------

declare -A GLYPH
GLYPH["0,0"]="█████"; GLYPH["0,1"]="█   █"; GLYPH["0,2"]="█   █"; GLYPH["0,3"]="█   █"; GLYPH["0,4"]="█████"
GLYPH["1,0"]="  █  "; GLYPH["1,1"]=" ██  "; GLYPH["1,2"]="  █  "; GLYPH["1,3"]="  █  "; GLYPH["1,4"]="█████"
GLYPH["2,0"]="█████"; GLYPH["2,1"]="    █"; GLYPH["2,2"]="█████"; GLYPH["2,3"]="█    "; GLYPH["2,4"]="█████"
GLYPH["3,0"]="█████"; GLYPH["3,1"]="    █"; GLYPH["3,2"]="█████"; GLYPH["3,3"]="    █"; GLYPH["3,4"]="█████"
GLYPH["4,0"]="█   █"; GLYPH["4,1"]="█   █"; GLYPH["4,2"]="█████"; GLYPH["4,3"]="    █"; GLYPH["4,4"]="    █"
GLYPH["5,0"]="█████"; GLYPH["5,1"]="█    "; GLYPH["5,2"]="█████"; GLYPH["5,3"]="    █"; GLYPH["5,4"]="█████"
GLYPH["6,0"]="█████"; GLYPH["6,1"]="█    "; GLYPH["6,2"]="█████"; GLYPH["6,3"]="█   █"; GLYPH["6,4"]="█████"
GLYPH["7,0"]="█████"; GLYPH["7,1"]="    █"; GLYPH["7,2"]="    █"; GLYPH["7,3"]="    █"; GLYPH["7,4"]="    █"
GLYPH["8,0"]="█████"; GLYPH["8,1"]="█   █"; GLYPH["8,2"]="█████"; GLYPH["8,3"]="█   █"; GLYPH["8,4"]="█████"
GLYPH["9,0"]="█████"; GLYPH["9,1"]="█   █"; GLYPH["9,2"]="█████"; GLYPH["9,3"]="    █"; GLYPH["9,4"]="█████"
GLYPH[":,0"]="   "; GLYPH[":,1"]=" █ "; GLYPH[":,2"]="   "; GLYPH[":,3"]=" █ "; GLYPH[":,4"]="   "
 
GLYPH_HEIGHT=5

# ------------------------------------------------------------------
# Manual de Ayuda
# ------------------------------------------------------------------
usage() {
  cat <<EOF
8bit-timer.sh -- Temporizdor retro estilo 8-bit

Uso: 
   $(basename "$0") <duración>

Formatos de duración aceptados:
   90		-> 90 segundos
   5m 		-> 5 minutos
   1h		-> 1 hora
   1:30		-> 1 minuto 30 segundos
   1:02:30	-> 1 hora 2 minutos 30 segundos

Sin argumentos, el script preguntará la duración de forma interactiva
EOF
}

# Métodos

# ------------------------------------------------------------------
# Convierte la entrada del usuario a segundos totales
# ------------------------------------------------------------------

parse_duration() {
  local input="$1"
 
  if [[ "$input" =~ ^([0-9]+):([0-9]{1,2}):([0-9]{1,2})$ ]]; then
    local h="${BASH_REMATCH[1]}" m="${BASH_REMATCH[2]}" s="${BASH_REMATCH[3]}"
    echo $(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
  elif [[ "$input" =~ ^([0-9]+):([0-9]{1,2})$ ]]; then
    local m="${BASH_REMATCH[1]}" s="${BASH_REMATCH[2]}"
    echo $(( 10#$m * 60 + 10#$s ))
  elif [[ "$input" =~ ^([0-9]+)[Hh]$ ]]; then
    echo $(( 10#${BASH_REMATCH[1]} * 3600 ))
  elif [[ "$input" =~ ^([0-9]+)[Mm]$ ]]; then
    echo $(( 10#${BASH_REMATCH[1]} * 60 ))
  elif [[ "$input" =~ ^([0-9]+)[Ss]?$ ]]; then
    echo $(( 10#${BASH_REMATCH[1]} ))
  else
    echo "-1"
  fi
}


# ------------------------------------------------------------------
# Dibuja una cadena (dígitos y ":") en grande, con un color dado
# ------------------------------------------------------------------

render_text() {
  local text="$1"
  local color="$2"
  local row line char
 
  for (( row=0; row<GLYPH_HEIGHT; row++ )); do
    line=""
    for (( i=0; i<${#text}; i++ )); do
      char="${text:$i:1}"
      line+="${GLYPH[$char,$row]}  "
    done
    echo -e "${color}${BOLD}${line}${RESET}"
  done
}


# ------------------------------------------------------------------
# Marco decorativo estilo consola retro
# ------------------------------------------------------------------
draw_frame_top() {
  local color="$1"
  echo -e "${color}${BOLD}╔══════════════════════════════════════╗${RESET}"
}
draw_frame_bottom() {
  local color="$1"
  echo -e "${color}${BOLD}╚══════════════════════════════════════╝${RESET}"
}
 
format_hms() {
  local total="$1"
  local h=$(( total / 3600 ))
  local m=$(( (total % 3600) / 60 ))
  local s=$(( total % 60 ))
  if (( h > 0 )); then
    printf "%d:%02d:%02d" "$h" "$m" "$s"
  else
    printf "%02d:%02d" "$m" "$s"
  fi
}


# ------------------------------------------------------------------
# Bucle principal del temporizador
# ------------------------------------------------------------------
run_timer() {
  local total="$1"
  local remaining="$total"
  local color_index=0
  local color
 
  tput civis 2>/dev/null || true
  trap 'tput cnorm 2>/dev/null || true; echo; exit 0' INT TERM
 
  while (( remaining >= 0 )); do
    color="${PALETTE[$(( color_index % COLOR_COUNT ))]}"
    clear
    echo
    draw_frame_top "$color"
    echo
    render_text "$(format_hms "$remaining")" "$color"
    echo
    draw_frame_bottom "$color"
    echo
    echo -e "${color}Ctrl+C para cancelar${RESET}"
 
    if (( remaining == 0 )); then
      break
    fi
 
    sleep 1
    remaining=$(( remaining - 1 ))
    color_index=$(( color_index + 1 ))
  done
 
  tput cnorm 2>/dev/null || true
 
  # Pantalla final parpadeante estilo "GAME OVER" de 8 bits
  local flash_colors=('\033[38;5;196m' '\033[38;5;226m')
  for i in 1 2 3 4 5 6; do
    clear
    c="${flash_colors[$(( i % 2 ))]}"
    echo
    draw_frame_top "$c"
    echo
    echo -e "${c}${BOLD}  ¡TIEMPO!  ${RESET}"
    echo
    draw_frame_bottom "$c"
    printf '\a'
    sleep 0.4
  done
  echo
}

# ------------------------------------------------------------------
# Punto de entrada
# ------------------------------------------------------------------
main() {
  local input="${1:-}"
 
  if [[ "$input" == "-h" || "$input" == "--help" ]]; then
    usage
    exit 0
  fi
 
  if [[ -z "$input" ]]; then
    read -rp "Duración (ej. 25m, 90, 1:30): " input
  fi
 
  local seconds
  seconds="$(parse_duration "$input")"
 
  if [[ "$seconds" == "-1" || "$seconds" -le 0 ]]; then
    echo "Duración no válida: '$input'" >&2
    usage
    exit 1
  fi
 
  run_timer "$seconds"
}
 
main "$@"
