# QR codes — what to print

Each code marks one spot on the library map. The app reads **only `id`** (a node id from
`mobile/assets/map/library_map.json`); `name` is optional and is only a label.

```json
{"id":"d_electrical","name":"قسم كهربية"}
```

- Encode the JSON as plain text, UTF-8, exactly as written (no spaces needed).
- A shorter payload makes a sparser, easier-to-scan code: `{"id":"d_electrical"}` works just as well.
- A bare id (`d_electrical`) or the old code (`QR04`) is still accepted.
- Ids are matched ignoring case and spaces. An id that is not on the map shows "Unrecognized QR code".

| Place | Payload to encode | Old code |
| --- | --- | --- |
| المدخل | `{"id":"entrance","name":"المدخل"}` | QR01 |
| قسم ميكانيكا | `{"id":"d_mechanical","name":"قسم ميكانيكا"}` | QR03 |
| قسم كهربية | `{"id":"d_electrical","name":"قسم كهربية"}` | QR04 |
| قسم مدنى | `{"id":"d_civil","name":"قسم مدنى"}` | QR05 |
| قسم عمارة | `{"id":"d_architecture","name":"قسم عمارة"}` | QR06 |
| دوريات علمية | `{"id":"d_periodicals","name":"دوريات علمية"}` | QR07 |
| رسائل علمية | `{"id":"d_theses","name":"رسائل علمية"}` | QR08 |
| مراجع | `{"id":"d_reference","name":"مراجع"}` | QR09 |
| امين المكتبة | `{"id":"librarian","name":"امين المكتبة"}` | — |

Corridor junctions (`N10`…`N17`) have no code; add one only if you want visitors to re-locate there —
any node id on the map resolves.
