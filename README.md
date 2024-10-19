# Assembly-Windows-App
Thanks to Dave's Garage
https://www.youtube.com/watch?v=b0zxIfJJLAY&t=1450s
***
instal masm32
***
Update line 11050 in winextra.inc as follows,
```
STD_ALERT struct
    alrt_timestamp dd ?
    alrt_eventname WCHAR (MARRY + 1) dup(?) ; corrected
    alrt_servicename WCHAR (SNLEN + 1) dup(?) ; corrected
STD_ALERT ends
```
***
and run
***
```
ml /coff app123.asm
```
