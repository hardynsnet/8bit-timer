# 8bit-timer 🎮⏱️

Un temporizador de cuenta regresiva para la terminal, con **estética retro 8-bit**: dígitos gigantes hechos de bloques, colores tipo consola vieja que cambian cada segundo, y una pantalla final parpadeante al estilo "GAME OVER".

Hecho 100% en **Bash**, sin dependencias externas.

---

## ✨ Características

- ⏳ Acepta duración en varios formatos: segundos, minutos, horas o `mm:ss` / `h:mm:ss`.
- 🎨 Paleta de colores ANSI que rota automáticamente segundo a segundo.
- 👾 Dígitos dibujados en bloques (estilo 8-bit / arcade).
- 🔔 Aviso sonoro (bell) y pantalla parpadeante `¡TIEMPO!` al terminar.
- 🖥️ Sin dependencias: solo Bash y `tput` (incluido en casi cualquier sistema tipo Unix).

## 📸 Vista previa

```
╔══════════════════════════════════════╗

█████  █████       █████  █████
█   █  █   █        █ █   █   █
█   █  █████         █    █████
█   █      █        █ █       █
█████  █████       █████  █████

╚══════════════════════════════════════╝

Ctrl+C para cancelar
```

*(los colores rotan cada segundo en la terminal real)*

## 🚀 Instalación

```bash
git clone https://github.com/hardynsnet/8bit-timer.git
cd 8bit-timer
chmod +x 8bit-timer.sh
```

## 🕹️ Uso

```bash
./8bit-timer.sh 25m        # 25 minutos
./8bit-timer.sh 90         # 90 segundos
./8bit-timer.sh 1:30       # 1 minuto 30 segundos
./8bit-timer.sh 1:02:30    # 1 hora, 2 minutos, 30 segundos
./8bit-timer.sh            # modo interactivo (te pregunta la duración)
```

Para cancelar el temporizador en cualquier momento, presiona `Ctrl+C`.

### Formatos de duración aceptados

| Formato   | Ejemplo   | Significado              |
|-----------|-----------|--------------------------|
| `Ns`      | `90`      | 90 segundos              |
| `Nm`      | `5m`      | 5 minutos                |
| `Nh`      | `1h`      | 1 hora                   |
| `m:s`     | `1:30`    | 1 minuto y 30 segundos   |
| `h:m:s`   | `1:02:30` | 1 hora, 2 min, 30 seg    |

## 🛠️ Cómo funciona

- Los dígitos `0-9` y `:` están definidos como *glifos* de 5x5 bloques (`█`) en un array asociativo de Bash.
- Cada segundo, el script limpia la pantalla, recalcula el tiempo restante y vuelve a dibujar los dígitos con el siguiente color de la paleta.
- Al llegar a cero, se repite una pantalla `¡TIEMPO!` parpadeante junto con el carácter de campana (`\a`) para avisar sonoramente.

## 🗺️ Roadmap / ideas futuras

- [ ] Soporte para temas de color personalizados.
- [ ] Modo "cuenta arriba" (cronómetro).
- [ ] Barra de progreso en bloques debajo del reloj.
- [ ] Notificación de escritorio al terminar (`notify-send`).

## 📄 Licencia

MIT — libre para usar, modificar y compartir.
