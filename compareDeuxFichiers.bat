@echo off
SETLOCAL enabledelayedexpansion

SET "pathFichier1=%~1"
SET "pathFichier2=%~2"
SET "nbLigneFichier1="
SET "nbLigneFichier2="

SET "nomFichierVBSindentique=fichierIdentique.vbs"
SET "nomFichierVBSdiff=fichierDifferences.vbs"
SET /a "nbDifference=0"


:: Code éxecuter (main) ::
FOR /l %%i IN (1, 1, 2) DO (
    call :choixFichierSource %%i
)

FOR /l %%i IN (1, 1, 2) DO (
    call :nomFichierTemp %%i
    call :nbLigneFichier %%i
)


:: Compare le nombre de ligne des deux fichiers ::
SET "msgFichierDiff=msgbox "
if "%nbLigneFichier1%" EQU "%nbLigneFichier2%" (
    call :compareFichiers
) else (
    echo %msgFichierDiff%"Le nombre de ligne des deux fichiers sont différentes" ^& vbCRLF ^& "%pathFichier1% = %nbLigneFichier1% Lignes" ^& vbCRLF ^& "%pathFichier2% = %nbLigneFichier2% Lignes", vbOkOnly+vbInformation > %nomFichierVBSdiff%
    call %nomFichierVBSdiff%
    del %nomFichierVBSdiff%
    call :suppressionFichierTemp
    goto :eof
)

:: Compare le contenue des deux fichiers ::
if "%nbDifference%" EQU "0" (
    ECHO msgbox "les fichiers ""%pathFichier1%"" et ""%pathFichier2%"" sont IDENTIQUES" > %nomFichierVBSindentique%
    call %nomFichierVBSindentique%
    del %nomFichierVBSindentique%
) else (
    echo %msgFichierDiff%"il y a %nbDifference% DIFFERENCES entre les fichiers ""%pathFichier1%"" et ""%pathFichier2%" > %nomFichierVBSdiff%
    call %nomFichierVBSdiff%
    del %nomFichierVBSdiff%
)

call :suppressionFichierTemp
ENDLOCAL
:: Met fin au programme ::
goto :eof



:: Vérifie si l'argument est valide ::
:choixFichierSource
    IF NOT EXIST "!pathFichier%~1!" (
        :: Demande à l'utilisateur de choisir un fichier 1 valide ::
        IF %~1==1 (
            SET /P "pathFichier%~1=Veuillez choisir le chemin et/ou le nom du 1er fichier à comparer : "
        ) ELSE (
            SET /P "pathFichier%~1=Veuillez choisir le chemin et/ou le nom du %~1ème fichier à comparer : "
        )
        goto :choixFichierSource %~1
    )
goto :eof


:: Vérifie si le nom du fichier temporaires existe déjà ::
:nomFichierTemp
    :: Compte le nombre de fichier présent dans le dossier ::
    FOR /f %%i IN ('dir "%cd%" /a:-d ^| find "fichier"') DO SET "nbFichier=%%i"

    :: Vérifie si le fichier existe déjà ::
    FOR /l %%C IN (1, 1, %nbFichier%) DO (
        IF NOT EXIST "temp%%C.txt" (
            SET "nomFichierTemp%~1=temp%%C.txt"
            goto :eof
        )
    )
goto :eof


:: Permet de connaitre le nombre de lignes dans les fichiers ::
:nbLigneFichier
    FIND /v /c "" < "!pathFichier%~1!" > "!nomFichierTemp%~1!"
    FOR /f "tokens=1 delims=" %%A IN (!nomFichierTemp%~1!) DO SET /a "nbLigneFichier%~1=%%A"
goto :eof


:: Boucle pour lire les deux fichiers ligne par ligne ::
:compareFichiers
    call :verifFichier "delims=" 0
    FOR /l %%C IN (1, 1, !nbLigneFichier1!) DO (
        call :verifFichier "delims= skip=%%C" %%C
        SET "rien="
    )
goto :eof


:: Permet de vérifier si les deux fichiers sont identiques et dans le même ordre ::
:verifFichier
    FOR /f "%~1" %%A IN ('type "!pathFichier1!"') DO (
        FOR /f "%~1" %%B IN ('type "!pathFichier2!"') DO (
            if NOT "%%A" EQU "%%B" (
                call :fichierDifferent %~2
            )
            goto :eof
        )
    )
goto :eof


:: Opération à faire si les fichiers sont différents ::
:fichierDifferent
    SET /a "nbDifference=%nbDifference%+1"
    SET /a "numLigneDifferent=%~1+1"
    SET "msgFichierDiff=%msgFichierDiff%"Différence à la ligne %numLigneDifferent%" ^& vbCRLF ^& "
goto :eof


:: Suppressions des fichiers temporaires ::
:suppressionFichierTemp
    del %nomFichierTemp1%
    del %nomFichierTemp2%
goto :eof