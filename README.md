# afbashlauncher

Do powstania została użyta Windowsowa kompilacja Linuksowego Shella:
https://sourceforge.net/projects/win-bash/

Proszę o zgłaszanie błędów i nadsyłanie propozycji nowych funkcjonalności.

Spis Treści
1. Dlaczego i po co?
2. Instrukcja instalacji.
3. Changelog.

##################################
Dlaczego i po co?

- automatycznie sprawdza na których portach są serwery oraz jeżeli są dwa, pozwala wybrać na który chcemy wejść.
- automatycznie pobiera listę wymaganych oraz dopuszczonych modów
- automatycznie sprawdza czy posiadamy wymagane mody (oraz włączone przez użytkownika dodatkowe mody)
- nie mamy pobranych modów skrypt sam je zasubskrybuje.
- automatycznie dobiera odpowiednie mody w zależności od modlisty
- automatycznie wstrzymuje start klienta Arma 3, jeżeli serwer jest OffLine oraz oczekuje na jego wstanie
- istnieje także możliwość wstrzymania startu klienta do rozpoczęcia misji
- jeżeli wszystko jest w porządku wystarczy dwuklik aby wejść na serwer - nie trzeba się tu przeklikiwać przez launcher
- czyszczenie starych modów
- szukanie nowych modlist
- wywalanie starych modów
- oraz wiele innych

* Instrukcja instalacji

DISCLAIMER!

 - Windows Defender nie ufa oprogramowaniu niepodpisanemu przez Microsoft (W Windows 10 dajemy Więcej Informacji->Uruchom Mimo To)
 - Zapora także nie ufa programowi wget.exe (do pobierania konfiguracji z FTP). Dlatego akceptujemy połączenie po odpowiednim prompterze.


- Pobieramy launcher
https://drive.google.com/file/d/1hyvW9DnZ1cAr7_LKWF68Q_wQvDC7rUwL/view?usp=sharing

- Rozpakowujemy paczkę.
- Dwuklikiem otwieramy armaforces.bat - musimy teraz przejść przez kreator pierwszej konfiguracji:
1. Podajemy hasło do serwera.
2. Otrzymujemy informację o stworzeniu pliku "parametry.txt". Służy on do wprowadzania naszych parametrów startowych (instrukcja w skrypcie).
3. Otrzymujemy informację o stworzeniu pliku "dodatkowemody.json". Służy on do włączania modów dodatkowych. Wszystkie mody dodatkowe są domyślnie włączone!
4. Następnie skrypt kieruje nas do kreatora wyboru modów dodatkowych. Tu można włączyć lub wyłączyć mody dodatkowe.
5. Jeżeli nie posiadamy wystarczającej liczby modów skrypt automatycznie zasubskrybuje i pobierze brakujące mody.
- jeżeli wszystko wykonaliśmy skrypt nie będzie już przy ponownym uruchomieniu o nic pytał (z wyjątkiem ew. zmiany modów). Wystarczy dwuklik.

Changelog

v12022022

- usunięty spadek po starym api (tj. pliki .cvs)
- dodana pełna obsługa plików JSON - w porównaniu do poprzednika jest dużo szybszy
jako, że jest szybszy, to teraz przy każdym uruchomieniu parsuje modlistę do pobrania, nie tak jak było poprzednio, tylko przy zmianie zawartości JSONa na zdalnym serwerze.
wywalone stare wyjście przy samym pobieraniu modów (już nie informuje o otwarciu kart przeglądarki ;p)

v14112021

- removed: autoclean.bat - potwierdzenie usunięcia modów
- fixed: poprawione czytanie CDLC z API
- added: wrzucanie bieżącej modlisty do oryginalnego launchera (jeżeli ktoś chce korzystać)
- added: wybór między odpalaniem bezpośrednim Army, a odpaleniem przez oryginalny launcher (wystarczy dodać plik “origlauncher” do folderu z launcherem)

v11082020

- added: zamiast pobierać wszystkie modlisty pobiera tylko na nadchodzące misje

v17072019beta

- changed: pobieranie danych o serwerze bezpośrednio przez klienta (dotąd były pobierane przez serwer launchera)
- changed: wszystkie modlisty są pobierane przez klienta oraz traktowane są każde z osobna
- added: czarnolisto - wywalanie starych modlist. Przydatne przy czyszczeniu starych modów.
- deleted: liberation.bat

Generalnie launcher w tej wersji działa bardziej samodzielnie. Serwera używa tylko do pobierania poprawek kodu.

v02052019

- changed: powiązanie launchera z generatorem by @veteran29 http://armaforces.maciejewski.cf/#

v20122018

- added: laucher z automatu startuje klienta Arma 3 z wysokim priorytetem. https://www.tenforums.com/tutorials/89548-set-cpu-process-priority-applications-windows-10-a.html

v26112018

- changed: teraz launcher działa z dowolnej lokalizacji (tj. nie trzeba go wklejać do folderu z Armą). Pobiera ścieżkę z: reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\bohemia interactive\arma 3" /v main

v25112018

- changed: WorkshopControl - oczekuje na pobranie modów
- changed: autoclean.bat - dodano funkcję "napraw": wyrzuca mody wylistowane w pliku cfg\dousuniecia.txt - przydatne w przypadku namierzenia uszkodzonych, niepobranych przez błąd klienta Steam modów. Można je później zasubskrybować na czysto.

v20112018

- added: util WorkshopControl.exe
- changed: patrz wyżej: pobieranie modów jest teraz realizowane przez powyższy program - ręczna subskrypcja ze strony nie jest już wymagana
- changed: patrz wyżej: podobnie z autoclean.bat - nie trzeba już ręcznie usuwać subskrypcji

v12112018

- fixed: poprawiono autoclean.bat

notka:
Ani samo odsubskrybowanie, ani usunięcie modów za pomocą launchera armowego nie usuwa modów z dysku. Co więcej - manifest appworkshop_107410.acf po odsubskrybowaniu nie jest modyfikowany przez klienta. To znaczy, że tak naprawdę nie pozbywamy się moda z dysku, a ręczne jego usunięcie upośledza update pozostałych modów (nie będą się updateować/nie można dodać nowych modów ponieważ linijka "SizeOnDisk"        "57563339354" jest niezmieniona i klient nie dostaje poprawnej informacji. Z moim skryptem usuwa moda z dysku oraz modyfikuje "appworkshop107410.acf" tak, aby klient nawet się nie zorientował, że coś jest nie tak ;).

Changelog

v11112018

- added: możliwość uruchomienia Army z najnowszym alokatorem pamięci TBB. Pobiera najnowszą wersję devtbbmalloc_bi_x64.dll i wkleja do folderu Dll. Wystarczy w pliku cfg\parametry.txt dodać wpis: "-malloc=devtbbmalloc_bi_x64". Zapraszam do testowania.
- added: kreator tworzenia pliku parametry.txt pyta o dodanie ww wpisu.

v09112018
- removed: usunięto opcję armaforces_czekaj_na_tematyczny.bat
- added: dodano opcję armaforces_czekaj_na_wieczorna_misje.bat. Teraz launcher wykrywa, czy ruszyła wieczorna misja w ogóle, nie tylko tematyczna. Bazuje na wykrywaniu w nazwie misji. Jeżeli misja nie nazywa się: "Arma 3", "Altis Lajf", wtedy dopiero launcher kontynuuje działanie. Zapraszam do testowania.
- changed: teraz launcher wyświetla dodatkowe info o serwerze/-ach.
- added: lokowanie produktu ;)

v01112018
- added: obsługa modów spoza Steam Workshop - dodaj moda do folderu "mods" w folderze lauchera



v27102018
- added: nowa funkcjonalność - automatyczne usuwanie nieużywanych modów. OSTROŻNIE!!! usuwane są wszystkie mody oprócz modów na serwerze (tematycznym i normalnym) i niewymienione w pliku DONOTDELETETHISMODS.txt (whitelista). Przekierowuje do Steam Workshop w celu odsubskrybowania następnie zwalnia dysk z nieużywanych modów. Uruchom autoclean.bat aby sprawdzić.
- changed: pliki konfiguracyjne zostały przeniesione do folderu cfg, a pliki tymczasowe do temp.
Changelog

v03102018
- added: nowa funkcjonalność - pokazywanie statusu serwera (mapa, misja, gracze). Odpal getinfo.bat aby sprawdzić.

v02102018
- added: nowa funkcjonalność - możliwość połączenia z serwerem z Liberacją. Użyj liberation.bat.
- fixed: usprawnienia wydajnościowe.

v16092018
- added: nowa funkcjonalność - kreator wyboru modów dodatkowych. Można edytować swoją listę modów za pomocą prostego kreatora. Aby sprawdzić uruchom armaforces_zmien_mody_dodatkowe.bat
- changed: teraz kreator wyboru modów dodatkowych uruchamia się razem z pierwszym uruchomieniem (żeby można było wykluczyć mody do ewentualnego pobrania)

v13092018
- added: przy uruchomieniu zamyka bieżącą sesję Arma 3
- added: nowa funkcjonalność - oczekiwanie na misję tematyczną: skrypt - zanim włączy klienta gry - będzie oczekiwał aż włączy się serwer z modami tematycznymi. Włącz armaforces_czekaj_na_tematyczny.bat aby uruchomić. (dysklejmer - armaforces.bat nadal pozwala na wejście z modami tematycznymi. Ww. funkcjonalność ma na celu tylko zwiększenie wygody, żeby nie trzeba było co chwilę patrzeć czy Wietnam już stoi, ;)) (dysklejmer2 - klient Arma 3 nie zamknie się dopóki nie wykryje serwera z modami tematycznymi)
- changed: sprawdzanie obecności modów od teraz sprawdza zarówno mody normalne jak i tematyczne (a nie jak wcześniej tylko aktualnie uruchomione na serwerze).

v10092018
- added: sprawdza, czy poprawnie umieściliśmy folder ze skryptami w folderze Arma 3

v09092018
- added: zmieniono sposób w jaki laucher łączy się z serwerem. Od teraz automatycznie wykrywa port oraz wybiera odpowiednią listę modów.
- added: jeżeli nie wykrywa serwera, oczekuje aż wstanie
- fixed: znowu spacje chromolone

v02092018
- added: Dodano przy pierwszym uruchomieniu popup “Insert kremówka!!!” ;)

v01092018:
- fix: poprawiono błąd gdzie ścieżka folderu z modami zawierająca spację wykrzaczała launcher (np. C:\Program Files (x86)\Steam…) (dzięki Bene)
