# =============================================================================
# Bosch HomeConnect - Dishwasher Status Monitor v1.4
# US NL version
# V. Jansen
# 2026-05-15
# ==============================================================================
# The script runs continuously and shows status changes as they occur.
# Stop with CTRL+C.
#
# SETUP (one time only):
# -----------------------------------------------------------------------
# 1. Create a free account at: https://developer.home-connect.com
#    (use the same email address as your HomeConnect app)
#
# 2. Go to: https://developer.home-connect.com/applications/add
#    Fill in:
#      - Application ID:  choose any name, e.g. "DishwasherMonitor"
#      - OAuth Flow:      select "Device Flow"
#      - Redirect URI:    http://localhost
#    Click Save.
#
# 3. Copy the Client ID and Client Secret and paste them below.
# -----------------------------------------------------------------------

# ======================== CONFIGURATION ========================

$ClientID        = "YOUR_CLIENT_ID_HERE"
$ClientSecret    = "YOUR_CLIENT_SECRET_HERE"

# How often to check for status updates (in seconds)
$PollingInterval = 30

# Where to store the access token between runs
$TokenFile       = "$env:USERPROFILE\homeconnect_token.json"

# ==============================================================


# ---------------------------------------------------------------
# LANGUAGE DETECTION
# Detects the Windows UI language and falls back to English.
# Supported: nl (Dutch), de (German), fr (French), es (Spanish),
#            it (Italian), pt (Portuguese), pl (Polish), tr (Turkish)
# ---------------------------------------------------------------
$systeemTaal = (Get-Culture).TwoLetterISOLanguageName.ToLower()

$talen = @{

    # ---- Labels (API sleutels naar leesbare namen) ----
    "labels" = @{
        "nl" = @{
            "BSH.Common.Status.DoorState"                       = "Deurstatus"
            "BSH.Common.Status.OperationState"                  = "Bedrijfsstatus"
            "BSH.Common.Status.RemoteControlActive"             = "Afstandsbediening actief"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Remote starten toegestaan"
            "BSH.Common.Status.LocalControlActive"              = "Lokale bediening actief"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Zout bijvullen nodig"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Glansspoelmiddel bijvullen nodig"
        }
        "de" = @{
            "BSH.Common.Status.DoorState"                       = "Tuerstatus"
            "BSH.Common.Status.OperationState"                  = "Betriebsstatus"
            "BSH.Common.Status.RemoteControlActive"             = "Fernsteuerung aktiv"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Fernstart erlaubt"
            "BSH.Common.Status.LocalControlActive"              = "Lokale Steuerung aktiv"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Salz nachfuellen"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Klarspueler nachfuellen"
        }
        "fr" = @{
            "BSH.Common.Status.DoorState"                       = "Etat de la porte"
            "BSH.Common.Status.OperationState"                  = "Etat de fonctionnement"
            "BSH.Common.Status.RemoteControlActive"             = "Telecommande active"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Demarrage a distance autorise"
            "BSH.Common.Status.LocalControlActive"              = "Commande locale active"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Recharge sel necessaire"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Recharge rincage necessaire"
        }
        "es" = @{
            "BSH.Common.Status.DoorState"                       = "Estado de la puerta"
            "BSH.Common.Status.OperationState"                  = "Estado de funcionamiento"
            "BSH.Common.Status.RemoteControlActive"             = "Control remoto activo"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Inicio remoto permitido"
            "BSH.Common.Status.LocalControlActive"              = "Control local activo"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Necesita sal"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Necesita abrillantador"
        }
        "it" = @{
            "BSH.Common.Status.DoorState"                       = "Stato sportello"
            "BSH.Common.Status.OperationState"                  = "Stato operativo"
            "BSH.Common.Status.RemoteControlActive"             = "Controllo remoto attivo"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Avvio remoto consentito"
            "BSH.Common.Status.LocalControlActive"              = "Controllo locale attivo"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Ricarica sale necessaria"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Ricarica brillantante necessaria"
        }
        "pt" = @{
            "BSH.Common.Status.DoorState"                       = "Estado da porta"
            "BSH.Common.Status.OperationState"                  = "Estado de funcionamento"
            "BSH.Common.Status.RemoteControlActive"             = "Controlo remoto ativo"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Inicio remoto permitido"
            "BSH.Common.Status.LocalControlActive"              = "Controlo local ativo"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Reabastecimento de sal necessario"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Reabastecimento de abrillantador necessario"
        }
        "pl" = @{
            "BSH.Common.Status.DoorState"                       = "Stan drzwi"
            "BSH.Common.Status.OperationState"                  = "Stan pracy"
            "BSH.Common.Status.RemoteControlActive"             = "Zdalne sterowanie aktywne"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Zdalny start dozwolony"
            "BSH.Common.Status.LocalControlActive"              = "Lokalne sterowanie aktywne"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Wymagane uzupelnienie soli"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Wymagane uzupelnienie plynu"
        }
        "tr" = @{
            "BSH.Common.Status.DoorState"                       = "Kapi durumu"
            "BSH.Common.Status.OperationState"                  = "Calisma durumu"
            "BSH.Common.Status.RemoteControlActive"             = "Uzaktan kumanda aktif"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Uzaktan baslarmaya izin var"
            "BSH.Common.Status.LocalControlActive"              = "Yerel kontrol aktif"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Tuz ikmali gerekli"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Parlaklik maddesi ikmali gerekli"
        }
        "en" = @{
            "BSH.Common.Status.DoorState"                       = "Door state"
            "BSH.Common.Status.OperationState"                  = "Operation state"
            "BSH.Common.Status.RemoteControlActive"             = "Remote control active"
            "BSH.Common.Status.RemoteControlStartAllowed"       = "Remote start allowed"
            "BSH.Common.Status.LocalControlActive"              = "Local control active"
            "Dishcare.Dishwasher.Status.SaltRefillNeeded"       = "Salt refill needed"
            "Dishcare.Dishwasher.Status.RinseAidRefillNeeded"   = "Rinse aid refill needed"
        }
    }

    # ---- Waarden (API enum waarden naar leesbare tekst) ----
    "values" = @{
        "nl" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Open"
            "BSH.Common.EnumType.DoorState.Closed"              = "Gesloten"
            "BSH.Common.EnumType.DoorState.Locked"              = "Vergrendeld"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inactief"
            "BSH.Common.EnumType.OperationState.Ready"          = "Gereed"
            "BSH.Common.EnumType.OperationState.Run"            = "Bezig"
            "BSH.Common.EnumType.OperationState.Pause"          = "Gepauzeerd"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Actie vereist"
            "BSH.Common.EnumType.OperationState.Finished"       = "Klaar"
            "BSH.Common.EnumType.OperationState.Error"          = "Fout"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Bezig met stoppen"
            "True"                                              = "Ja"
            "False"                                             = "Nee"
        }
        "de" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Offen"
            "BSH.Common.EnumType.DoorState.Closed"              = "Geschlossen"
            "BSH.Common.EnumType.DoorState.Locked"              = "Verriegelt"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inaktiv"
            "BSH.Common.EnumType.OperationState.Ready"          = "Bereit"
            "BSH.Common.EnumType.OperationState.Run"            = "Laeuft"
            "BSH.Common.EnumType.OperationState.Pause"          = "Pausiert"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Aktion erforderlich"
            "BSH.Common.EnumType.OperationState.Finished"       = "Fertig"
            "BSH.Common.EnumType.OperationState.Error"          = "Fehler"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Wird abgebrochen"
            "True"                                              = "Ja"
            "False"                                             = "Nein"
        }
        "fr" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Ouverte"
            "BSH.Common.EnumType.DoorState.Closed"              = "Fermee"
            "BSH.Common.EnumType.DoorState.Locked"              = "Verrouillee"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inactif"
            "BSH.Common.EnumType.OperationState.Ready"          = "Pret"
            "BSH.Common.EnumType.OperationState.Run"            = "En cours"
            "BSH.Common.EnumType.OperationState.Pause"          = "En pause"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Action requise"
            "BSH.Common.EnumType.OperationState.Finished"       = "Termine"
            "BSH.Common.EnumType.OperationState.Error"          = "Erreur"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Annulation en cours"
            "True"                                              = "Oui"
            "False"                                             = "Non"
        }
        "es" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Abierta"
            "BSH.Common.EnumType.DoorState.Closed"              = "Cerrada"
            "BSH.Common.EnumType.DoorState.Locked"              = "Bloqueada"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inactivo"
            "BSH.Common.EnumType.OperationState.Ready"          = "Listo"
            "BSH.Common.EnumType.OperationState.Run"            = "En marcha"
            "BSH.Common.EnumType.OperationState.Pause"          = "En pausa"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Accion requerida"
            "BSH.Common.EnumType.OperationState.Finished"       = "Terminado"
            "BSH.Common.EnumType.OperationState.Error"          = "Error"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Cancelando"
            "True"                                              = "Si"
            "False"                                             = "No"
        }
        "it" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Aperto"
            "BSH.Common.EnumType.DoorState.Closed"              = "Chiuso"
            "BSH.Common.EnumType.DoorState.Locked"              = "Bloccato"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inattivo"
            "BSH.Common.EnumType.OperationState.Ready"          = "Pronto"
            "BSH.Common.EnumType.OperationState.Run"            = "In corso"
            "BSH.Common.EnumType.OperationState.Pause"          = "In pausa"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Azione richiesta"
            "BSH.Common.EnumType.OperationState.Finished"       = "Terminato"
            "BSH.Common.EnumType.OperationState.Error"          = "Errore"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Annullamento in corso"
            "True"                                              = "Si"
            "False"                                             = "No"
        }
        "pt" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Aberta"
            "BSH.Common.EnumType.DoorState.Closed"              = "Fechada"
            "BSH.Common.EnumType.DoorState.Locked"              = "Bloqueada"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inativo"
            "BSH.Common.EnumType.OperationState.Ready"          = "Pronto"
            "BSH.Common.EnumType.OperationState.Run"            = "A funcionar"
            "BSH.Common.EnumType.OperationState.Pause"          = "Em pausa"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Acao necessaria"
            "BSH.Common.EnumType.OperationState.Finished"       = "Concluido"
            "BSH.Common.EnumType.OperationState.Error"          = "Erro"
            "BSH.Common.EnumType.OperationState.Aborting"       = "A cancelar"
            "True"                                              = "Sim"
            "False"                                             = "Nao"
        }
        "pl" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Otwarte"
            "BSH.Common.EnumType.DoorState.Closed"              = "Zamkniete"
            "BSH.Common.EnumType.DoorState.Locked"              = "Zablokowane"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Nieaktywny"
            "BSH.Common.EnumType.OperationState.Ready"          = "Gotowy"
            "BSH.Common.EnumType.OperationState.Run"            = "W trakcie"
            "BSH.Common.EnumType.OperationState.Pause"          = "Wstrzymany"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Wymagana akcja"
            "BSH.Common.EnumType.OperationState.Finished"       = "Zakonczony"
            "BSH.Common.EnumType.OperationState.Error"          = "Blad"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Anulowanie"
            "True"                                              = "Tak"
            "False"                                             = "Nie"
        }
        "tr" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Acik"
            "BSH.Common.EnumType.DoorState.Closed"              = "Kapali"
            "BSH.Common.EnumType.DoorState.Locked"              = "Kilitli"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Etkin degil"
            "BSH.Common.EnumType.OperationState.Ready"          = "Hazir"
            "BSH.Common.EnumType.OperationState.Run"            = "Calisiyor"
            "BSH.Common.EnumType.OperationState.Pause"          = "Duraklatildi"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Islem gerekli"
            "BSH.Common.EnumType.OperationState.Finished"       = "Tamamlandi"
            "BSH.Common.EnumType.OperationState.Error"          = "Hata"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Iptal ediliyor"
            "True"                                              = "Evet"
            "False"                                             = "Hayir"
        }
        "en" = @{
            "BSH.Common.EnumType.DoorState.Open"                = "Open"
            "BSH.Common.EnumType.DoorState.Closed"              = "Closed"
            "BSH.Common.EnumType.DoorState.Locked"              = "Locked"
            "BSH.Common.EnumType.OperationState.Inactive"       = "Inactive"
            "BSH.Common.EnumType.OperationState.Ready"          = "Ready"
            "BSH.Common.EnumType.OperationState.Run"            = "Running"
            "BSH.Common.EnumType.OperationState.Pause"          = "Paused"
            "BSH.Common.EnumType.OperationState.ActionRequired" = "Action required"
            "BSH.Common.EnumType.OperationState.Finished"       = "Finished"
            "BSH.Common.EnumType.OperationState.Error"          = "Error"
            "BSH.Common.EnumType.OperationState.Aborting"       = "Aborting"
            "True"                                              = "Yes"
            "False"                                             = "No"
        }
    }

    # ---- UI teksten ----
    "ui" = @{
        "nl" = @{
            "auth_header"        = "===== HOMECONNECT AUTHENTICATIE ====="
            "auth_step1"         = "Stap 1: Autorisatie aanvragen..."
            "auth_step2"         = "Stap 2: Open deze URL en log in met je HomeConnect account:"
            "auth_approve"       = "Klik op Approve in de browser."
            "auth_enter"         = "Druk op ENTER nadat je Approve hebt geklikt"
            "auth_step3"         = "Stap 3: Token ophalen..."
            "auth_success"       = "Succesvol ingelogd!"
            "auth_error_id"      = "Controleer of je Client ID correct is."
            "auth_error_approve" = "Heb je wel op Approve geklikt?"
            "auth_error"         = "Fout bij authenticatie"
            "auth_token_error"   = "Token ophalen mislukt"
            "token_found"        = "Token gevonden ({0} uur oud)."
            "token_no_token"     = "Geen opgeslagen token gevonden. Eenmalig inloggen vereist."
            "token_renewing"     = "Token verlopen, wordt vernieuwd..."
            "token_renewed"      = "Token vernieuwd."
            "token_renew_fail"   = "Token vernieuwen mislukt"
            "token_relogin"      = "Token verlopen. Opnieuw inloggen..."
            "devices_loading"    = "Apparaten ophalen..."
            "devices_error"      = "Fout bij ophalen apparaten"
            "devices_none"       = "Geen apparaten gevonden in je HomeConnect account."
            "devices_found"      = "Gevonden apparaten:"
            "dishwasher_found"   = "Vaatwasser gevonden"
            "dishwasher_none"    = "Geen vaatwasser gevonden. Beschikbare apparaten:"
            "status_header"      = "===== HUIDIGE STATUS"
            "status_device"      = "Apparaat"
            "status_connected"   = "Verbonden"
            "status_yes"         = "Ja"
            "status_no"          = "Nee"
            "monitor_started"    = "Monitoring gestart. Controle elke {0} seconden. Druk CTRL+C om te stoppen."
            "no_changes"         = "Geen wijzigingen"
            "change_header"      = "===== WIJZIGING GEDETECTEERD"
            "status_error"       = "Fout bij ophalen status"
            "retry"              = "Volgende poging over {0} seconden..."
            "lang_detected"      = "Taal gedetecteerd"
        }
        "de" = @{
            "auth_header"        = "===== HOMECONNECT AUTHENTIFIZIERUNG ====="
            "auth_step1"         = "Schritt 1: Autorisierung anfordern..."
            "auth_step2"         = "Schritt 2: Diese URL oeffnen und mit HomeConnect-Konto anmelden:"
            "auth_approve"       = "Klicken Sie im Browser auf Approve."
            "auth_enter"         = "ENTER druecken nachdem Sie Approve geklickt haben"
            "auth_step3"         = "Schritt 3: Token abrufen..."
            "auth_success"       = "Erfolgreich angemeldet!"
            "auth_error_id"      = "Bitte Client ID pruefen."
            "auth_error_approve" = "Haben Sie Approve geklickt?"
            "auth_error"         = "Fehler bei der Authentifizierung"
            "auth_token_error"   = "Token abrufen fehlgeschlagen"
            "token_found"        = "Token gefunden ({0} Stunden alt)."
            "token_no_token"     = "Kein gespeichertes Token. Einmalige Anmeldung erforderlich."
            "token_renewing"     = "Token abgelaufen, wird erneuert..."
            "token_renewed"      = "Token erneuert."
            "token_renew_fail"   = "Token erneuern fehlgeschlagen"
            "token_relogin"      = "Token abgelaufen. Erneut anmelden..."
            "devices_loading"    = "Geraete werden abgerufen..."
            "devices_error"      = "Fehler beim Abrufen der Geraete"
            "devices_none"       = "Keine Geraete im HomeConnect-Konto gefunden."
            "devices_found"      = "Gefundene Geraete:"
            "dishwasher_found"   = "Geschirrspueler gefunden"
            "dishwasher_none"    = "Kein Geschirrspueler gefunden. Verfuegbare Geraete:"
            "status_header"      = "===== AKTUELLER STATUS"
            "status_device"      = "Geraet"
            "status_connected"   = "Verbunden"
            "status_yes"         = "Ja"
            "status_no"          = "Nein"
            "monitor_started"    = "Ueberwachung gestartet. Pruefung alle {0} Sekunden. CTRL+C zum Beenden."
            "no_changes"         = "Keine Aenderungen"
            "change_header"      = "===== AENDERUNG ERKANNT"
            "status_error"       = "Fehler beim Abrufen des Status"
            "retry"              = "Naechster Versuch in {0} Sekunden..."
            "lang_detected"      = "Sprache erkannt"
        }
        "fr" = @{
            "auth_header"        = "===== AUTHENTIFICATION HOMECONNECT ====="
            "auth_step1"         = "Etape 1: Demande d'autorisation..."
            "auth_step2"         = "Etape 2: Ouvrez cette URL et connectez-vous avec votre compte HomeConnect:"
            "auth_approve"       = "Cliquez sur Approve dans le navigateur."
            "auth_enter"         = "Appuyez sur ENTREE apres avoir clique sur Approve"
            "auth_step3"         = "Etape 3: Recuperation du token..."
            "auth_success"       = "Connexion reussie!"
            "auth_error_id"      = "Verifiez votre Client ID."
            "auth_error_approve" = "Avez-vous clique sur Approve?"
            "auth_error"         = "Erreur d'authentification"
            "auth_token_error"   = "Echec de recuperation du token"
            "token_found"        = "Token trouve ({0} heures)."
            "token_no_token"     = "Aucun token enregistre. Connexion unique requise."
            "token_renewing"     = "Token expire, renouvellement en cours..."
            "token_renewed"      = "Token renouvele."
            "token_renew_fail"   = "Echec du renouvellement du token"
            "token_relogin"      = "Token expire. Reconnexion..."
            "devices_loading"    = "Chargement des appareils..."
            "devices_error"      = "Erreur lors du chargement des appareils"
            "devices_none"       = "Aucun appareil trouve dans le compte HomeConnect."
            "devices_found"      = "Appareils trouves:"
            "dishwasher_found"   = "Lave-vaisselle trouve"
            "dishwasher_none"    = "Aucun lave-vaisselle trouve. Appareils disponibles:"
            "status_header"      = "===== STATUT ACTUEL"
            "status_device"      = "Appareil"
            "status_connected"   = "Connecte"
            "status_yes"         = "Oui"
            "status_no"          = "Non"
            "monitor_started"    = "Surveillance demarree. Verification toutes les {0} secondes. CTRL+C pour arreter."
            "no_changes"         = "Aucun changement"
            "change_header"      = "===== CHANGEMENT DETECTE"
            "status_error"       = "Erreur lors de la recuperation du statut"
            "retry"              = "Prochain essai dans {0} secondes..."
            "lang_detected"      = "Langue detectee"
        }
        "es" = @{
            "auth_header"        = "===== AUTENTICACION HOMECONNECT ====="
            "auth_step1"         = "Paso 1: Solicitando autorizacion..."
            "auth_step2"         = "Paso 2: Abra esta URL e inicie sesion con su cuenta HomeConnect:"
            "auth_approve"       = "Haga clic en Approve en el navegador."
            "auth_enter"         = "Pulse ENTER despues de hacer clic en Approve"
            "auth_step3"         = "Paso 3: Obteniendo token..."
            "auth_success"       = "Inicio de sesion correcto!"
            "auth_error_id"      = "Compruebe su Client ID."
            "auth_error_approve" = "Ha hecho clic en Approve?"
            "auth_error"         = "Error de autenticacion"
            "auth_token_error"   = "Error al obtener el token"
            "token_found"        = "Token encontrado ({0} horas)."
            "token_no_token"     = "No se encontro token. Se requiere inicio de sesion unico."
            "token_renewing"     = "Token caducado, renovando..."
            "token_renewed"      = "Token renovado."
            "token_renew_fail"   = "Error al renovar el token"
            "token_relogin"      = "Token caducado. Volviendo a iniciar sesion..."
            "devices_loading"    = "Cargando dispositivos..."
            "devices_error"      = "Error al cargar los dispositivos"
            "devices_none"       = "No se encontraron dispositivos en la cuenta HomeConnect."
            "devices_found"      = "Dispositivos encontrados:"
            "dishwasher_found"   = "Lavavajillas encontrado"
            "dishwasher_none"    = "No se encontro lavavajillas. Dispositivos disponibles:"
            "status_header"      = "===== ESTADO ACTUAL"
            "status_device"      = "Dispositivo"
            "status_connected"   = "Conectado"
            "status_yes"         = "Si"
            "status_no"          = "No"
            "monitor_started"    = "Supervision iniciada. Comprobacion cada {0} segundos. CTRL+C para detener."
            "no_changes"         = "Sin cambios"
            "change_header"      = "===== CAMBIO DETECTADO"
            "status_error"       = "Error al obtener el estado"
            "retry"              = "Proximo intento en {0} segundos..."
            "lang_detected"      = "Idioma detectado"
        }
        "it" = @{
            "auth_header"        = "===== AUTENTICAZIONE HOMECONNECT ====="
            "auth_step1"         = "Passo 1: Richiesta autorizzazione..."
            "auth_step2"         = "Passo 2: Apri questo URL e accedi con il tuo account HomeConnect:"
            "auth_approve"       = "Fai clic su Approve nel browser."
            "auth_enter"         = "Premi INVIO dopo aver fatto clic su Approve"
            "auth_step3"         = "Passo 3: Recupero del token..."
            "auth_success"       = "Accesso riuscito!"
            "auth_error_id"      = "Verifica il tuo Client ID."
            "auth_error_approve" = "Hai fatto clic su Approve?"
            "auth_error"         = "Errore di autenticazione"
            "auth_token_error"   = "Recupero del token non riuscito"
            "token_found"        = "Token trovato ({0} ore)."
            "token_no_token"     = "Nessun token salvato. Accesso unico richiesto."
            "token_renewing"     = "Token scaduto, rinnovamento in corso..."
            "token_renewed"      = "Token rinnovato."
            "token_renew_fail"   = "Rinnovo del token non riuscito"
            "token_relogin"      = "Token scaduto. Nuovo accesso..."
            "devices_loading"    = "Caricamento dispositivi..."
            "devices_error"      = "Errore nel caricamento dei dispositivi"
            "devices_none"       = "Nessun dispositivo trovato nell'account HomeConnect."
            "devices_found"      = "Dispositivi trovati:"
            "dishwasher_found"   = "Lavastoviglie trovata"
            "dishwasher_none"    = "Nessuna lavastoviglie trovata. Dispositivi disponibili:"
            "status_header"      = "===== STATO ATTUALE"
            "status_device"      = "Dispositivo"
            "status_connected"   = "Connesso"
            "status_yes"         = "Si"
            "status_no"          = "No"
            "monitor_started"    = "Monitoraggio avviato. Controllo ogni {0} secondi. CTRL+C per fermare."
            "no_changes"         = "Nessuna modifica"
            "change_header"      = "===== MODIFICA RILEVATA"
            "status_error"       = "Errore nel recupero dello stato"
            "retry"              = "Prossimo tentativo tra {0} secondi..."
            "lang_detected"      = "Lingua rilevata"
        }
        "pt" = @{
            "auth_header"        = "===== AUTENTICACAO HOMECONNECT ====="
            "auth_step1"         = "Passo 1: A solicitar autorizacao..."
            "auth_step2"         = "Passo 2: Abra este URL e inicie sessao com a sua conta HomeConnect:"
            "auth_approve"       = "Clique em Approve no browser."
            "auth_enter"         = "Prima ENTER apos clicar em Approve"
            "auth_step3"         = "Passo 3: A obter token..."
            "auth_success"       = "Sessao iniciada com sucesso!"
            "auth_error_id"      = "Verifique o seu Client ID."
            "auth_error_approve" = "Clicou em Approve?"
            "auth_error"         = "Erro de autenticacao"
            "auth_token_error"   = "Falha ao obter token"
            "token_found"        = "Token encontrado ({0} horas)."
            "token_no_token"     = "Sem token guardado. Inicio de sessao unico necessario."
            "token_renewing"     = "Token expirado, a renovar..."
            "token_renewed"      = "Token renovado."
            "token_renew_fail"   = "Falha ao renovar token"
            "token_relogin"      = "Token expirado. A reiniciar sessao..."
            "devices_loading"    = "A carregar dispositivos..."
            "devices_error"      = "Erro ao carregar dispositivos"
            "devices_none"       = "Nenhum dispositivo encontrado na conta HomeConnect."
            "devices_found"      = "Dispositivos encontrados:"
            "dishwasher_found"   = "Maquina de lavar loica encontrada"
            "dishwasher_none"    = "Nenhuma maquina encontrada. Dispositivos disponiveis:"
            "status_header"      = "===== ESTADO ATUAL"
            "status_device"      = "Dispositivo"
            "status_connected"   = "Ligado"
            "status_yes"         = "Sim"
            "status_no"          = "Nao"
            "monitor_started"    = "Monitorizacao iniciada. Verificacao a cada {0} segundos. CTRL+C para parar."
            "no_changes"         = "Sem alteracoes"
            "change_header"      = "===== ALTERACAO DETETADA"
            "status_error"       = "Erro ao obter estado"
            "retry"              = "Proxima tentativa em {0} segundos..."
            "lang_detected"      = "Idioma detetado"
        }
        "pl" = @{
            "auth_header"        = "===== UWIERZYTELNIANIE HOMECONNECT ====="
            "auth_step1"         = "Krok 1: Zadanie autoryzacji..."
            "auth_step2"         = "Krok 2: Otworz ten URL i zaloguj sie na konto HomeConnect:"
            "auth_approve"       = "Kliknij Approve w przegladarce."
            "auth_enter"         = "Nacisnij ENTER po kliknieciu Approve"
            "auth_step3"         = "Krok 3: Pobieranie tokenu..."
            "auth_success"       = "Zalogowano pomyslnie!"
            "auth_error_id"      = "Sprawdz swoje Client ID."
            "auth_error_approve" = "Czy kliknales Approve?"
            "auth_error"         = "Blad uwierzytelniania"
            "auth_token_error"   = "Nie udalo sie pobrac tokenu"
            "token_found"        = "Znaleziono token ({0} godz.)."
            "token_no_token"     = "Brak zapisanego tokenu. Wymagane jednorazowe logowanie."
            "token_renewing"     = "Token wygasl, odnawianie..."
            "token_renewed"      = "Token odnowiony."
            "token_renew_fail"   = "Nie udalo sie odnowic tokenu"
            "token_relogin"      = "Token wygasl. Ponowne logowanie..."
            "devices_loading"    = "Pobieranie urzadzen..."
            "devices_error"      = "Blad podczas pobierania urzadzen"
            "devices_none"       = "Nie znaleziono urzadzen na koncie HomeConnect."
            "devices_found"      = "Znalezione urzadzenia:"
            "dishwasher_found"   = "Znaleziono zmywarke"
            "dishwasher_none"    = "Nie znaleziono zmywarki. Dostepne urzadzenia:"
            "status_header"      = "===== AKTUALNY STATUS"
            "status_device"      = "Urzadzenie"
            "status_connected"   = "Polaczone"
            "status_yes"         = "Tak"
            "status_no"          = "Nie"
            "monitor_started"    = "Monitorowanie uruchomione. Sprawdzanie co {0} sekund. CTRL+C aby zatrzymac."
            "no_changes"         = "Brak zmian"
            "change_header"      = "===== WYKRYTO ZMIANE"
            "status_error"       = "Blad podczas pobierania statusu"
            "retry"              = "Nastepna proba za {0} sekund..."
            "lang_detected"      = "Wykryto jezyk"
        }
        "tr" = @{
            "auth_header"        = "===== HOMECONNECT KIMLIK DOGRULAMA ====="
            "auth_step1"         = "Adim 1: Yetkilendirme istegi..."
            "auth_step2"         = "Adim 2: Bu URL'yi acin ve HomeConnect hesabinizla giris yapin:"
            "auth_approve"       = "Tarayicida Approve'a tiklayın."
            "auth_enter"         = "Approve'a tikladiktan sonra ENTER'a basin"
            "auth_step3"         = "Adim 3: Token aliniyor..."
            "auth_success"       = "Basariyla giris yapildi!"
            "auth_error_id"      = "Client ID'nizi kontrol edin."
            "auth_error_approve" = "Approve'a tikladiniz mi?"
            "auth_error"         = "Kimlik dogrulama hatasi"
            "auth_token_error"   = "Token alinamadi"
            "token_found"        = "Token bulundu ({0} saat)."
            "token_no_token"     = "Kayitli token yok. Tek seferlik giris gerekli."
            "token_renewing"     = "Token suresi doldu, yenileniyor..."
            "token_renewed"      = "Token yenilendi."
            "token_renew_fail"   = "Token yenilenemedi"
            "token_relogin"      = "Token suresi doldu. Yeniden giris..."
            "devices_loading"    = "Cihazlar yukleniyor..."
            "devices_error"      = "Cihazlar yuklenirken hata"
            "devices_none"       = "HomeConnect hesabinda cihaz bulunamadi."
            "devices_found"      = "Bulunan cihazlar:"
            "dishwasher_found"   = "Bulasik makinesi bulundu"
            "dishwasher_none"    = "Bulasik makinesi bulunamadi. Mevcut cihazlar:"
            "status_header"      = "===== MEVCUT DURUM"
            "status_device"      = "Cihaz"
            "status_connected"   = "Bagli"
            "status_yes"         = "Evet"
            "status_no"          = "Hayir"
            "monitor_started"    = "Izleme basladi. Her {0} saniyede bir kontrol. Durdurmak icin CTRL+C."
            "no_changes"         = "Degisiklik yok"
            "change_header"      = "===== DEGISIKLIK ALGILANDI"
            "status_error"       = "Durum alinirken hata"
            "retry"              = "Sonraki deneme {0} saniye sonra..."
            "lang_detected"      = "Dil algilandi"
        }
        "en" = @{
            "auth_header"        = "===== HOMECONNECT AUTHENTICATION ====="
            "auth_step1"         = "Step 1: Requesting authorization..."
            "auth_step2"         = "Step 2: Open this URL and sign in with your HomeConnect account:"
            "auth_approve"       = "Click Approve in the browser."
            "auth_enter"         = "Press ENTER after clicking Approve"
            "auth_step3"         = "Step 3: Retrieving token..."
            "auth_success"       = "Successfully signed in!"
            "auth_error_id"      = "Please check your Client ID."
            "auth_error_approve" = "Did you click Approve?"
            "auth_error"         = "Authentication error"
            "auth_token_error"   = "Failed to retrieve token"
            "token_found"        = "Token found ({0} hours old)."
            "token_no_token"     = "No saved token found. One-time login required."
            "token_renewing"     = "Token expired, renewing..."
            "token_renewed"      = "Token renewed."
            "token_renew_fail"   = "Failed to renew token"
            "token_relogin"      = "Token expired. Signing in again..."
            "devices_loading"    = "Loading devices..."
            "devices_error"      = "Error loading devices"
            "devices_none"       = "No devices found in your HomeConnect account."
            "devices_found"      = "Devices found:"
            "dishwasher_found"   = "Dishwasher found"
            "dishwasher_none"    = "No dishwasher found. Available devices:"
            "status_header"      = "===== CURRENT STATUS"
            "status_device"      = "Device"
            "status_connected"   = "Connected"
            "status_yes"         = "Yes"
            "status_no"          = "No"
            "monitor_started"    = "Monitoring started. Checking every {0} seconds. Press CTRL+C to stop."
            "no_changes"         = "No changes"
            "change_header"      = "===== CHANGE DETECTED"
            "status_error"       = "Error retrieving status"
            "retry"              = "Next attempt in {0} seconds..."
            "lang_detected"      = "Language detected"
        }
    }
}

# Kies de taal, val terug op Engels als de taal niet beschikbaar is
if ($talen["ui"].ContainsKey($systeemTaal)) {
    $taal = $systeemTaal
} else {
    $taal = "en"
}

$ui  = $talen["ui"][$taal]
$lbl = $talen["labels"][$taal]
$val = $talen["values"][$taal]

Write-Host "$($ui['lang_detected']): $taal" -ForegroundColor DarkGray


# ---------------------------------------------------------------
# HULPFUNCTIES
# ---------------------------------------------------------------
function T($key) { return $ui[$key] }

function Sla-TokenOp($TokenData) {
    $TokenData | ConvertTo-Json | Set-Content -Path $TokenFile -Encoding UTF8
}

function Laad-Token {
    if (Test-Path $TokenFile) {
        return Get-Content $TokenFile -Raw | ConvertFrom-Json
    }
    return $null
}

function Vernieuw-Token($RefreshToken) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $(T 'token_renewing')" -ForegroundColor Yellow
    $body = @{
        grant_type    = "refresh_token"
        client_id     = $ClientID
        client_secret = $ClientSecret
        refresh_token = $RefreshToken
    }
    try {
        $response = Invoke-RestMethod -Method POST `
            -Uri "https://api.home-connect.com/security/oauth/token" `
            -ContentType "application/x-www-form-urlencoded" `
            -Body $body
        $response | Add-Member -NotePropertyName "saved_at" -NotePropertyValue (Get-Date).ToString("o") -Force
        Sla-TokenOp $response
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $(T 'token_renewed')" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $(T 'token_renew_fail'): $_" -ForegroundColor Red
        return $null
    }
}

function Authenticeer {
    Write-Host ""
    Write-Host (T "auth_header") -ForegroundColor Cyan
    Write-Host (T "auth_step1") -ForegroundColor Yellow

    $body = @{
        client_id = $ClientID
        scope     = "IdentifyAppliance Monitor"
    }

    try {
        $authResponse = Invoke-RestMethod -Method POST `
            -Uri "https://api.home-connect.com/security/oauth/device_authorization" `
            -ContentType "application/x-www-form-urlencoded" `
            -Body $body
    }
    catch {
        Write-Host "$(T 'auth_error'): $_" -ForegroundColor Red
        Write-Host (T "auth_error_id") -ForegroundColor Yellow
        exit
    }

    Write-Host ""
    Write-Host (T "auth_step2") -ForegroundColor Green
    Write-Host ""
    Write-Host "   $($authResponse.verification_uri_complete)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host (T "auth_approve") -ForegroundColor Yellow
    Write-Host ""

    try { Start-Process $authResponse.verification_uri_complete } catch {}

    Read-Host (T "auth_enter")

    Write-Host ""
    Write-Host (T "auth_step3") -ForegroundColor Yellow

    $body2 = @{
        client_id     = $ClientID
        client_secret = $ClientSecret
        grant_type    = "device_code"
        device_code   = $authResponse.device_code
    }

    try {
        $tokenResponse = Invoke-RestMethod -Method POST `
            -Uri "https://api.home-connect.com/security/oauth/token" `
            -ContentType "application/x-www-form-urlencoded" `
            -Body $body2
        $tokenResponse | Add-Member -NotePropertyName "saved_at" -NotePropertyValue (Get-Date).ToString("o") -Force
        Sla-TokenOp $tokenResponse
        Write-Host (T "auth_success") -ForegroundColor Green
        return $tokenResponse
    }
    catch {
        Write-Host "$(T 'auth_token_error'): $_" -ForegroundColor Red
        Write-Host (T "auth_error_approve") -ForegroundColor Yellow
        exit
    }
}

function Haal-TokenDatum($token) {
    # Accepteer zowel 'saved_at' (nieuw) als 'opgeslagen_op' (oud veld)
    $datumStr = if ($token.saved_at) { $token.saved_at } elseif ($token.opgeslagen_op) { $token.opgeslagen_op } else { $null }
    if ($null -eq $datumStr) { return $null }
    try {
        return [datetime]::Parse($datumStr)
    }
    catch {
        return $null
    }
}

function Zorg-VoorGeldigToken($token) {
    $savedAt        = Haal-TokenDatum $token
    if ($null -eq $savedAt) {
        # Datum onleesbaar: forceer opnieuw inloggen
        Write-Host (T "token_relogin") -ForegroundColor Yellow
        return Authenticeer
    }
    $leeftijdInUren = ((Get-Date) - $savedAt).TotalHours

    if ($leeftijdInUren -gt 23) {
        if ($token.refresh_token) {
            $nieuw = Vernieuw-Token $token.refresh_token
            if ($null -ne $nieuw) { return $nieuw }
        }
        Write-Host (T "token_relogin") -ForegroundColor Yellow
        return Authenticeer
    }
    return $token
}

function Vertaal-Sleutel($key) {
    if ($lbl.ContainsKey($key)) { return $lbl[$key] }
    return $key
}

function Vertaal-Waarde($value) {
    $str = $value.ToString()
    if ($val.ContainsKey($str)) { return $val[$str] }
    return $str
}

function Kleur-Van-Waarde($sleutel, $waarde) {
    # Kleur op basis van de ruwe API waarde zodat het taaalonafhankelijk werkt
    if ($waarde -eq $val["BSH.Common.EnumType.OperationState.Run"])            { return "Cyan"   }
    if ($waarde -eq $val["BSH.Common.EnumType.OperationState.Finished"])       { return "Green"  }
    if ($waarde -eq $val["BSH.Common.EnumType.OperationState.ActionRequired"]) { return "Yellow" }
    if ($waarde -eq $val["BSH.Common.EnumType.OperationState.Error"])          { return "Red"    }
    if ($waarde -eq $val["BSH.Common.EnumType.DoorState.Open"])                { return "Yellow" }
    if ($waarde -eq $val["True"]  -and $sleutel -match ($lbl["Dishcare.Dishwasher.Status.SaltRefillNeeded"]     -replace " ","." )) { return "Red"   }
    if ($waarde -eq $val["True"]  -and $sleutel -match ($lbl["Dishcare.Dishwasher.Status.RinseAidRefillNeeded"] -replace " ",".")) { return "Red"   }
    if ($waarde -eq $val["False"] -and $sleutel -match ($lbl["Dishcare.Dishwasher.Status.SaltRefillNeeded"]     -replace " ",".")) { return "Green" }
    if ($waarde -eq $val["False"] -and $sleutel -match ($lbl["Dishcare.Dishwasher.Status.RinseAidRefillNeeded"] -replace " ",".")) { return "Green" }
    return "White"
}

function Toon-VolledigeStatus($statusItems, $apparaat) {
    Write-Host ""
    Write-Host "$(T 'status_header') - $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') =====" -ForegroundColor Cyan
    Write-Host "  $(T 'status_device')     : $($apparaat.name)" -ForegroundColor White
    $verb = if ($apparaat.connected) { T "status_yes" } else { T "status_no" }
    Write-Host "  $(T 'status_connected') : $verb" -ForegroundColor White
    Write-Host "  --------------------------------------------------"

    foreach ($item in $statusItems) {
        $sleutel = Vertaal-Sleutel $item.key
        $waarde  = Vertaal-Waarde  $item.value
        $kleur   = Kleur-Van-Waarde $sleutel $waarde
        $regel   = "  {0,-40} : " -f $sleutel
        Write-Host $regel -NoNewline -ForegroundColor Gray
        Write-Host $waarde -ForegroundColor $kleur
    }
    Write-Host ""
}

function Haal-StatusOp($haId, $header) {
    $response = Invoke-RestMethod `
        -Uri "https://api.home-connect.com/api/homeappliances/$haId/status" `
        -Method GET `
        -Headers $header
    return $response.data.status
}

function Status-NaarHashtable($statusItems) {
    $ht = @{}
    foreach ($item in $statusItems) {
        $ht[$item.key] = $item.value.ToString()
    }
    return $ht
}


# ---------------------------------------------------------------
# OPSTARTEN: Token ophalen
# ---------------------------------------------------------------
$token = Laad-Token

if ($null -eq $token) {
    Write-Host (T "token_no_token") -ForegroundColor Cyan
    $token = Authenticeer
}
else {
    $tokenDatum    = Haal-TokenDatum $token
    if ($null -ne $tokenDatum) {
        $leeftijdAfger = [math]::Round(((Get-Date) - $tokenDatum).TotalHours, 1)
        Write-Host ($ui["token_found"] -f $leeftijdAfger) -ForegroundColor Green
    }
    $token = Zorg-VoorGeldigToken $token
}

$header = @{ "Authorization" = "Bearer $($token.access_token)" }


# ---------------------------------------------------------------
# APPARATEN OPHALEN
# ---------------------------------------------------------------
Write-Host ""
Write-Host (T "devices_loading") -ForegroundColor Cyan

try {
    $apparaten     = Invoke-RestMethod -Uri "https://api.home-connect.com/api/homeappliances" -Method GET -Headers $header
    $alleApparaten = $apparaten.data.homeappliances
}
catch {
    Write-Host "$(T 'devices_error'): $_" -ForegroundColor Red
    exit
}

$vaatwasser = $alleApparaten | Where-Object { $_.type -eq "Dishwasher" } | Select-Object -First 1

if ($null -eq $vaatwasser) {
    Write-Host (T "dishwasher_none") -ForegroundColor Yellow
    foreach ($app in $alleApparaten) { Write-Host "  - $($app.type): $($app.name)" }
    exit
}

Write-Host "$(T 'dishwasher_found'): $($vaatwasser.name)" -ForegroundColor Green
$haId = $vaatwasser.haId


# ---------------------------------------------------------------
# EERSTE STATUS OPHALEN EN WEERGEVEN
# ---------------------------------------------------------------
try {
    $huidigStatusItems = Haal-StatusOp $haId $header
    Toon-VolledigeStatus $huidigStatusItems $vaatwasser
    $vorigeStatus      = Status-NaarHashtable $huidigStatusItems
}
catch {
    Write-Host "$(T 'status_error'): $_" -ForegroundColor Red
    exit
}


# ---------------------------------------------------------------
# MONITORING LOOP
# ---------------------------------------------------------------
Write-Host ($ui["monitor_started"] -f $PollingInterval) -ForegroundColor Cyan
Write-Host ""

while ($true) {

    Start-Sleep -Seconds $PollingInterval

    $token  = Zorg-VoorGeldigToken $token
    $header = @{ "Authorization" = "Bearer $($token.access_token)" }

    try {
        $nieuweStatusItems = Haal-StatusOp $haId $header
        $nieuweStatus      = Status-NaarHashtable $nieuweStatusItems

        $wijzigingen = @()
        foreach ($key in $nieuweStatus.Keys) {
            $nieuweWaarde = $nieuweStatus[$key]
            $oudeWaarde   = if ($vorigeStatus.ContainsKey($key)) { $vorigeStatus[$key] } else { $null }

            if ($nieuweWaarde -ne $oudeWaarde) {
                $wijzigingen += [PSCustomObject]@{
                    Sleutel      = Vertaal-Sleutel $key
                    OudeWaarde   = if ($null -ne $oudeWaarde) { Vertaal-Waarde $oudeWaarde } else { "(?)" }
                    NieuweWaarde = Vertaal-Waarde $nieuweWaarde
                }
            }
        }

        if ($wijzigingen.Count -gt 0) {
            Write-Host "$(T 'change_header') - $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss') =====" -ForegroundColor Yellow

            foreach ($w in $wijzigingen) {
                $kleur = Kleur-Van-Waarde $w.Sleutel $w.NieuweWaarde
                $regel = "  {0,-40} : " -f $w.Sleutel
                Write-Host $regel -NoNewline -ForegroundColor Gray
                Write-Host "$($w.OudeWaarde)  -->  " -NoNewline -ForegroundColor DarkGray
                Write-Host $w.NieuweWaarde -ForegroundColor $kleur
            }

            Write-Host ""
            $vorigeStatus = $nieuweStatus
        }
        # Geen wijzigingen: niets weergeven
    }
    catch {
        Write-Host "$(T 'status_error'): $_" -ForegroundColor Red
        Write-Host ($ui["retry"] -f $PollingInterval) -ForegroundColor DarkGray
    }
}
