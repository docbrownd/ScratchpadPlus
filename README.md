# ScratchpadPlus
Scratchpad fork with automatic WPT creation

Lors de la prise d'une coordonnée, une nouvelle ligne commençant par un "*" apparait : c'est la ligne qui sera insérée dans l'ordinateur de bord. 
Si on ne souhaite pas intégrer une coordonnée, il suffit de supprimer l'astérisque.

Pour le F18, l'insertion se fait à partir de WPT n°2 et non du 1 (afin de préserver l'existence possible d'un WPT de type bullseye)

ATTENTION : s'il existe des WPT au delà du n°1, ils seront écrasés

Utilisation : 

F18 : 
	- dans HSI>DATA, boxer "Precise" 
	- au niveau de l'AMPCD : Afficher n'importe quelle page, SAUF la page "TAC"
	- cliquer sur "insert" et attendre 


A10 : 
	- il est possible de nommer un WPT, pour cela ajouter le nom juste après l'astérique et avant le premier '|'. ex : 

	*|N 41°55.590'|E 044°10.440'|3140 => *T90|N 41°55.590'|E 044°10.440'|3140  => le WPT aura pour nom "T90"

	- afficher le CDU 
	- cliquer sur "insert" et attendre
	

NB : si vous ajoutez une coordonnée dans scratchpad et que vous avez déjà inséré les autres, l'ensemble des coordonnées seront de nouveau insérées dans l'ordinateur de bord,
il faut donc soit effacer les coordonnées précédentes, soit retirer l'astérisque


A venir : possibilité d'indiquer à partir de quel WPT insérer les suivant