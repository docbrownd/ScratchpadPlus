# ScratchpadPlus
Fork de Scratchpad avec création automatique de WPT

## Installation

L'installation et l'utilisation se fait de la même manière que pour Scratchpad voir ici : https://github.com/rkusa/dcs-scratchpad

## Lancement
L'ouverture du logiciel se fait par défaut via le raccourci : ctrl+shift+w

## Création de WPT

Lors de la prise d'une coordonnée, une nouvelle ligne commençant par un astérique apparait : c'est la ligne qui sera insérée dans l'ordinateur de bord. 
Si on ne souhaite pas intégrer une coordonnée, il suffit de supprimer l'astérisque.

ATTENTION : s'il existe des WPT, ils seront écrasés


#### F18 : 

- dans HSI>DATA, boxer "Precise" 
- au niveau de l'AMPCD : Afficher n'importe quelle page, SAUF la page "TAC"
- cliquer sur "insert" et attendre 


#### A10 : 

- il est possible de nommer un WPT, pour cela ajouter le nom juste après l'astérique et avant le premier '|'.

	ex : *|N 41°55.590'|E 044°10.440'|3140 => *T90|N 41°55.590'|E 044°10.440'|3140  => le WPT aura pour nom "T90"

- aller sur l'écran CDU, Page WPT
- cliquer sur "insert" et attendre

- Remarque : L'A10 ne permet de rentrer que 50 WPT, une fois cette limite atteinte, il est nécessaire de modifier les WPT déjà créés. Pour indiquer à ScratchpadPlus qu'il doit modifier les WPT, il faut insérer un # au niveau de la première ligne de ScratchpadPlus. 

#### M2000 :

-cliquer simplement sur "insert"
	

#### F16 : 

- -cliquer simplement sur "insert"

##
NB : si vous ajoutez une coordonnée dans scratchpad et que vous avez déjà inséré les autres, l'ensemble des coordonnées seront de nouveau insérées dans l'ordinateur de bord, il faut donc soit effacer les coordonnées précédentes, soit retirer l'astérisque


#### F15E

Phase de TEST, le fonctionnement décrit ci-après peut fortement changer à court terme. 

Pour le F15E, le programme fonctionne différemment du fait que la création de WPT dans cet appareil est particulier. En effet il est nécessaire de saisir manuellement le numro du WPT à créer (impossible de faire +1) et pour avoir un WPT d'attaque, il faut créer des targets points (numéro de WPT suivi d'un point). Hors en cas de présence d'un target point, il n'est plus possible d'éditer le WPT (sans numéro) initial, car il n'existe plus. 

Ces différentes contraintes expliquent le fonctionnement suivant : 

- faites un 'clear' du logiciel => obligatoire !
- prennez vos WPT comme d'habitude
- Placez vous sur le menu (cf image ci-après)
- Cliquer sur insert

Le programme va alors :
 - insérer les WPT en partant de 1 et les modifier en target point
 - utiliser le canal B afin de conserver toute route qui serait créées dans A (ATTENTION : B ne doit donc pas être utilisé)

L'impossibilité d'éditer automatiquement un WPT une fois ce dernier passer en target point fait que le programme fera +1 pour chaque WPT, tant que DCS ne sera pas redémarré. 
Pour le forcer à revenir à 1, il faut ajouter, juste avant le premier 'insert', le caratère # au niveau de la première ligne de ScratchpadPlus. 

![image](https://github.com/docbrownd/ScratchpadPlus/assets/105074220/aa1a5550-6345-49af-bb9a-9c86730bfcad)





