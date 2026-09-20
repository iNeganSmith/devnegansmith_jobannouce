# negan_jobannouncements

Sistema standalone de anuncios públicos de servicios para FiveM, creado por **DevNeganSmith**.

Compatible con:

- Qbox / QBX
- QBCore
- ESX Legacy

El recurso detecta automáticamente el framework al iniciar y permite que jobs autorizados publiquen anuncios visibles para todos los jugadores mediante `/anuncio`.

## Características

- Un solo recurso para QBX, QBCore y ESX Legacy.
- Detección automática de framework con prioridad QBX → QBCore → ESX.
- Validación de job y duty del lado del servidor.
- Cooldown server-side por licencia del jugador cuando está disponible.
- Mensaje máximo configurable.
- NUI moderna y responsive.
- Cola de anuncios configurable.
- Duración configurable; por defecto 10 segundos.
- Ubicación obtenida desde las coordenadas server-side del jugador y resuelta a calle/zona por los clientes.
- Logos reemplazables por job.
- Colores configurables por job.
- Sonido NUI opcional.
- Sin loops permanentes de polling.
- No requiere base de datos.
- No modifica otros recursos.

## Instalación

1. Copia la carpeta `negan_jobannouncements` dentro de:

```text
resources/[standalone]/negan_jobannouncements
```

2. Asegúrate de iniciar tu framework antes de este recurso.

3. Añade al `server.cfg`:

```cfg
ensure negan_jobannouncements
```

4. Reinicia el servidor o ejecuta:

```text
ensure negan_jobannouncements
```

## Uso

```text
/anuncio Se necesitan unidades en Legion Square
```

El servidor detecta automáticamente el job del jugador. El usuario no puede escoger manualmente el tipo de anuncio, logo o nombre del servicio.

Jobs incluidos:

- `police`
- `ambulance`
- `mechanic`

## Configuración principal

Archivo: `config.lua`

```lua
Config.Framework = 'auto'
Config.Command = 'anuncio'
Config.Duration = 10000
Config.Cooldown = 30
Config.MaxMessageLength = 150
Config.ShowLocation = true
Config.RequireDuty = true
Config.EnableQueue = true
Config.MaxQueue = 5
Config.Sound = true
Config.SoundVolume = 0.20
Config.Position = 'top-center'
```

### Framework

Valores disponibles:

```lua
Config.Framework = 'auto'
Config.Framework = 'qbx'
Config.Framework = 'qbcore'
Config.Framework = 'esx'
```

Se recomienda `auto`.

## Duty

QBX y QBCore utilizan `job.onduty`.

ESX Legacy moderno puede exponer `job.onDuty`. Algunos forks antiguos no tienen duty en el job. Para esos casos:

```lua
Config.ESXAssumeOnDutyIfMissing = true
```

- `true`: si ESX no entrega un campo duty, el jugador autorizado puede anunciar.
- `false`: si no existe información de duty, el anuncio se bloquea.

## Agregar nuevos jobs

Añade otra entrada en `Config.Jobs`:

```lua
taxi = {
    label = 'SERVICIO DE TAXI',
    subtitle = 'TRANSPORTE DISPONIBLE',
    logo = 'taxi.png',
    accent = '#F1D54A',
    accentSoft = 'rgba(241, 213, 74, 0.20)'
}
```

Después coloca:

```text
html/img/jobs/taxi.png
```

No es necesario editar HTML, CSS ni JavaScript.

## Cambiar logos

Ruta:

```text
html/img/jobs/
```

Incluidos:

```text
police.png
ambulance.png
mechanic.png
```

Puedes reemplazar esos archivos por tus propios logos manteniendo sus nombres.

Se recomienda PNG transparente y cuadrado, por ejemplo 256×256 o 512×512.

## Ubicación

Cuando `Config.ShowLocation = true`, el servidor obtiene las coordenadas actuales del ped mediante natives server-side. Esas coordenadas se envían con el anuncio y cada cliente traduce la posición a zona/calle mediante natives de GTA.

De esta forma, la ubicación no depende de un texto enviado por el jugador que ejecuta `/anuncio`.

Si no se puede resolver una calle/zona, aparece `Ubicación no disponible`.

## Cola

```lua
Config.EnableQueue = true
Config.MaxQueue = 5
```

Si llegan varios anuncios mientras uno ya está visible, esperan su turno.

Con la cola desactivada, el anuncio nuevo reemplaza al actual.

## Sonido

```lua
Config.Sound = true
Config.SoundVolume = 0.20
Config.SoundFile = 'sounds/notify.wav'
```

Puedes reemplazar:

```text
html/sounds/notify.wav
```

por tu propio WAV.

## Posición

Valores disponibles:

```lua
Config.Position = 'top-center'
Config.Position = 'top-left'
Config.Position = 'top-right'
```

## Seguridad

Las comprobaciones sensibles se realizan en servidor:

- source válido;
- framework;
- personaje;
- job;
- duty;
- cooldown;
- longitud del mensaje;
- normalización del contenido.

El cliente no decide el job, el logo, el label ni los colores del anuncio.

La NUI inserta el contenido del jugador con `textContent`; no utiliza `innerHTML` para el mensaje.

## Eventos internos

Servidor → cliente:

```text
negan_jobannouncements:client:notify
negan_jobannouncements:client:showAnnouncement
```

No existe un evento cliente → servidor para crear anuncios. El anuncio nace directamente desde el comando registrado en el servidor, reduciendo superficie de abuso.

## Rendimiento

El recurso no utiliza loops `while true` ni polling permanente.

Cuando no hay anuncios, el cliente únicamente mantiene listeners de eventos y la NUI está inactiva. El consumo esperado en reposo debe ser prácticamente 0.00 ms, aunque el valor exacto depende del FXServer, hardware y profiler/resmon.

## Pruebas recomendadas

1. Entrar como civil y ejecutar `/anuncio prueba`: debe bloquearse.
2. Entrar como policía fuera de servicio: debe bloquearse si `RequireDuty = true`.
3. Entrar en servicio y publicar un anuncio.
4. Confirmar que todos los jugadores reciben el mismo anuncio.
5. Confirmar que aparece el logo correcto.
6. Confirmar zona/calle.
7. Confirmar duración de 10 segundos.
8. Intentar publicar nuevamente antes del cooldown.
9. Probar mensajes de más de 150 caracteres.
10. Publicar anuncios seguidos desde varios jobs y validar la cola.
11. Probar resoluciones 16:9 y 21:9.
12. Revisar F8 por errores JavaScript.
13. Revisar consola server por errores Lua.
14. Ejecutar `resmon 1` y revisar consumo en reposo y durante un anuncio.

## Estructura

```text
negan_jobannouncements/
├── fxmanifest.lua
├── config.lua
├── client/
│   ├── framework.lua
│   └── main.lua
├── server/
│   ├── framework.lua
│   └── main.lua
├── locales/
│   └── es.lua
├── html/
│   ├── index.html
│   ├── css/style.css
│   ├── js/app.js
│   ├── img/jobs/
│   │   ├── police.png
│   │   ├── ambulance.png
│   │   └── mechanic.png
│   └── sounds/notify.wav
└── README.md
```

## Autor

**DevNeganSmith**
