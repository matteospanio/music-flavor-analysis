# Analisi statistica per studio "Musica e Gusto"

## Formalizzazione

Ogni brano ha un vettore target (ground truth) associato:
$$
\mathbf{t}_i = (salty, sweet, sour, bitter, spicy)
$$

(metadata del dataset / query target)

- Ogni partecipante ascolta 10 brani campionati casualmente da un pool di 20 brani
- Per ogni brano fornisce un vettore percettivo Likert (1-7):
    $$
    \mathbf{p}_{ij} = (salty, sweet, sour, bitter, spicy)
    $$

Dove i = brano, j = partecipante

## Ipotesi

$H_0$: Il vettore percettivo non e' correlato al vettore target (associazione casuale)

$H_1$: Esiste una relazione sistematica tra metadate del brano e percezione gustativa

## Analisi dei dati
### Preparazione dei dati
- Preparare il dataset nella forma:
    $$
    \{ (\mathbf{t}_i, \mathbf{p}_{ij}) \mid i = 1, \ldots, 20; j = 1, \ldots, N_i \}
    $$
  dove $N_i$ è il numero di partecipanti che hanno valutato il brano $i$.
- Normalizzare perché le scale di valutazione possano essere confrontate (le scale likert sono diverse dai valori target), per questo abbiamo bisogno di fare $z$-score per ciascuna dimensione del vettore percettivo:
    $$
    \mathbf{p}_{ij}^{norm} = \frac{\mathbf{p}_{ij} - \mu_j}{\sigma_j}
    $$
  dove $\mu_j$ e $\sigma_j$ sono la media e la deviazione standard delle valutazioni per la dimensione $j$.
  Ci aspettiamo che la varianza spuria venga ridotta in questo modo.
- Individuazione di outlier: rimuovere partecipanti che hanno tutte le valutazioni uguali (varianza zero), e.g. che hanno risposto 1 a tutte le domande.

### Statistica descrittiva
#### Per dimensione
- Calcolare la media e deviazione standard delle valutazioni percettive per ogni dimensione gustativa:
    $$\mu_j = \frac{1}{M} \sum_{i=1}^{20} \sum_{k=1}^{N_i} p_{ikj}$$
    $$\sigma_j = \sqrt{\frac{1}{M} \sum_{i=1}^{20} \sum_{k=1}^{N_i} (p_{ikj} - \mu_j)^2}$$
  dove $M = \sum_{i=1}^{20} N_i$ è il numero totale di valutazioni.
  Cosi facendo vogliamo controllare ceiling e floor effects.
- Visualizzare le distribuzioni delle valutazioni per ogni dimensione gustativa usando istogrammi o boxplot.

#### Per brano
- Per ogni brano i, calcolare il vettore percettivo medio su tutti i partecipanti j che hanno valutato il brano:
    $$
    \bar{\mathbf{p}}_i = \frac{1}{N_i} \sum_{j=1}^{N_i} \mathbf{p}_{ij}
    $$
- Calcolare la distanza tra vettore target e vettore percettivo medio per ogni brano i:
    $$
    d_i = \| \mathbf{t}_i - \bar{\mathbf{p}}_i \|
    $$
- Ottenere la distribuzione delle distanze osservate:
    $$D_{obs} = \{ d_1, d_2, \ldots, d_{20} \}$$
- Calcolare la distanza media osservata:
    $$\bar{d}_{obs} = \frac{1}{20} \sum_{i=1}^{20} d_i$$

### Test principale di non-causalità (CORE CLAIM)

#### Permutation test sulla distanza vettoriale
- permutation test su distanza target-perceived:
    - Per ogni brano i, calcolare la distanza tra vettore target e vettore percettivo medio:
        $$
        d_i = \| \mathbf{t}_i - \bar{\mathbf{p}}_i \|
        $$
    - Calcolare la distanza media osservata:
        $$\bar{d}_{obs} = \frac{1}{20} \sum_{i=1}^{20} d_i$$
    - Creare una distribuzione nulla delle distanze medie tramite permutazione:
        - Per k = 1 a 10.000:
            - Permutare casualmente le associazioni tra brani e valutazioni percettive.
            - Per ogni brano i, calcolare la distanza tra vettore target e vettore percettivo medio permutato:
                $$
                d_i^{perm} = \| \mathbf{t}_i - \bar{\mathbf{p}}_i^{perm} \|
                $$
            - Calcolare la distanza media permutata:
                $$\bar{d}_{perm}^{(k)} = \frac{1}{20} \sum_{i=1}^{20} d_i^{perm}$$
        - Ottenere la distribuzione nulla delle distanze medie permutate:
            $$D_{null} = \{ \bar{d}_{perm}^{(1)}, \bar{d}_{perm}^{(2)}, \ldots, \bar{d}_{perm}^{(10000)} \}$$
    - Calcolare il p-value come la proporzione di distanze medie permutate che sono minori o uguali alla distanza media osservata:
        $$
        p = \frac{1}{10000} \sum_{k=1}^{10000} I(\bar{d}_{perm}^{(k)} \leq \bar{d}_{obs})
        $$
      dove I è la funzione indicatrice.

**Perché?** Il test e' multivariato, non parametrico e indipendente da assunzioni sulla scala Likert.

**Cosa verifica?** Se la similarita osservata e' superiore a quella attesa per caso ($H_0$).

Se otteniamo $p < 0.05$, possiamo rifiutare l'ipotesi nulla e concludere che esiste una relazione sistematica tra le metadate del brano e la percezione gustativa.

### Analisi secondarie (opzionali)
- Analisi per dimensione gustativa: calcolare correlazioni tra ogni dimensione del vettore target e la corrispondente dimensione del vettore percettivo medio (test di Spearman, uno per dimensione), applicare correzione per test multipli (Bonferroni).
- linear mixed-effects model: modello lineare misto con valutazioni percettive come variabile dipendente, vettori target come variabili fisse, partecipante come effetto casuale.
  ```{r}
  perceived ~ target + (1 | subject) + (1 | track)
  ```
  - Ci aspettiamo un $\beta_{target} > 0$ e significativo
- Inter rater reliability: calcolare l'affidabilita' tra partecipanti per ogni brano (ICC), per verificare coerenza nelle valutazioni (verifica che ci sia accordo tra partecipanti).
- bias analysis: verificare se ci sono bias dati da fattori demografici (età, genere) usando modelli misti/anova:
    ```{r}
    perceived ~ target * gender + (1 | subject) + (1 | track)
    ```
