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


## TODO
- possibilité d'indiquer à partir de quel WPT insérer les suivants


