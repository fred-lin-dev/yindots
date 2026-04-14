# Référence du prompt Starship

```
(づ ◕‿‿◕)づ ~/repo/src (main) !2 ?1 ⇡1
❯
```

## Répertoire

| Symbole       | Signification                        |
|---------------|--------------------------------------|
| `yinpi`       | Répertoire home (`~`)                |
| `…/foo/bar`   | Chemin tronqué (max 3 segments)      |

## Branche Git

| Symbole          | Signification              |
|------------------|----------------------------|
| ` (main)`       | Branche courante           |

## Statut Git

| Symbole   | Signification                              |
|-----------|--------------------------------------------|
| `+2`      | 2 fichiers stagés (prêts au commit)        |
| `!2`      | 2 fichiers modifiés (non stagés)           |
| `?1`      | 1 fichier non-tracké                       |
| `-1`      | 1 fichier supprimé                         |
| `»1`      | 1 fichier renommé                          |
| `≡`       | Stash présent                              |
| `⇡1`      | 1 commit en avance sur le remote (à push)  |
| `⇣1`      | 1 commit en retard sur le remote (à pull)  |
| `⇕`       | Divergé (avance ET retard)                 |
| ` `      | Conflit de merge                           |

## Code de retour

| Symbole     | Signification                      |
|-------------|------------------------------------|
| `✘ 1`       | Dernière commande a échoué (code 1)|
| `✘ 127`     | Commande introuvable               |
| `✘ 130`     | Interrompue par Ctrl+C             |
| *(absent)*  | Succès (code 0)                    |

## Caractère de fin

| Symbole         | Signification        |
|-----------------|----------------------|
| `❯` (vert)      | Prêt, succès         |
| `❯` (rouge)     | Dernière commande KO |
