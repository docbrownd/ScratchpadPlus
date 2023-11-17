# ScratchpadPlus
Fork de Scratchpad avec création automatique de WPT

## Installation

L'installation et l'utilisation se fait de la même manière que pour Scratchpad voir ici : https://github.com/rkusa/dcs-scratchpad

## Lancement
L'ouverture du logiciel se fait par défaut via le raccourci : ctrl+shift+w

## Config possible

Sur la plupart des appareils, l'insertion se fait en apuuyant puis en relâchant une touche, or il faut un certains entre ces deux actions pour qu'elles fonctionnent correctement. Il n'est pas possible sur DCS d'attendre un temps déterminé, le seul moyen est d'utiliser un compteur qui s'incrémente à chaque image. Le compteur est donc dépendant du nombre de fps de l'utilisateur. Or il peut aller trop vite ou pas assez vite, il est donc possible depuis la 1.6 de modifier la vitesse d'appuie : 
- insérer en haut de la fenêtre la commande suivante : #\*2 => multiplie par 2 la durée d'appuie sur une touche. 
- la nouvelle configuration est sauvegardée il n'est donc pas nécessaire de la retaper à chaque fois
=> les caractères #* sont obligatoires, ensuite à vous de trouver les valeurs qui vont avec votre système. Pour information, le programme a été codé avec 150fps. 
Moins vous avez de fps et plus le réglage de base est lent, il faut donc accélérer l'insertion des coordonnées, par exemple de 2x => #*0.5

Pour les utilisateurs en VR : il est possible de forcer la fenetre à s'ouvrir toujours au même endroit : 
- Ouvrée la fenêtre en VR et positionnée là où vous voulez.
- Fermer la fenêtre 
- Au niveau du fichier de configuration (dossier DCS dans partie enregistrées puis dossier Config => fichier ScratchpadPlusConfig.lua), ajouter "["vr"] = true," (sans les ") dans la partie config

## Export des WPT 

Depuis la 1.6, un bouton Export est présent en base de la fenêtre : il permet d'exporter le contenu de la fenêtre vers un fichier "coordonnees.txt" se trouvant dans le dossier ScratchpadPlus de DCS (dans Partie enregistrées). Il est alors possible de donner ce fichier à d'autres personnes ayant ScratchpadPlus. Pour l'intégrer automatiquement dans l'interface, il suffit de copier le ficheir dans le même dossier et d'utiliser les boutons "précédents/suivants".

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

- Remarque : L'A10 ne permet de rentrer que 50 WPT, une fois cette limite atteinte, il est nécessaire de modifier les WPT déjà créés. Pour indiquer à ScratchpadPlus qu'il doit modifier les WPT, il faut insérer ## au niveau de la première ligne de ScratchpadPlus. 

#### M2000 :

- cliquer simplement sur "insert"
	

#### F16 : 

- cliquer simplement sur "insert"
- Attention : il n'est possible d'insérer que 20 WPT. Après la manière d'ajouter un WPT change sur le F16 car il s'agit d'autres types de WPT (ex en 25 c'est le BE). Il faudra dont revenir manuellement au WPT 1. 

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
 - insérer les WPT en partant de 1 ~~et les modifier en target point~~ (non valable à partir de la 1.3)
 - utiliser le canal B afin de conserver toute route qui serait créées dans A (ATTENTION : B ne doit donc pas être utilisé)
 - A partir de la version 1.3 : si un point est ajouté manuellement entre * et | alors le WPT sera transformé en Target Point. (ex *.|N 41°55.590'|E 044°10.440'|3140|1 => le WPT 1B sera converti en 1.B)
 - A partir de la version 1.5 : si les caractères #. sont ajoutés en haut de la fenêtre, alors l'ensemble des waypoints seront convertis en target point
 - A partir de la 1.7, un bouton "target" est disponible : il insert les WPT dans le F15 et les convertis en TargetPoint. 

 ### F15E et JDAM

A partir de la version 1.9, il est possible, sous certaines conditions, d'assigner automatiquement un waypont à une bombe. Pour cela il faut avoir les bons paramètres (attention, cela va forcément changer suite aux maj à venir des JDAM): 
 - les coordonnées sont rentrées au format target point et dans la route B
 - l'UFC est sur la première page de Menu (avec LAW en PB1)
 - le programme de larguage est configuré pour 9 (si GBU38) ou 7 bombes (si GBU31)
 - l'avion est en mode A/G 
 - le MFD de droite est sur la page SMART WPT et la première bombe (L1) est sélectionnée
   
Rentrer ensuite la commande suivante au niveau de la première ligne de ScratchpadPlus :

<code>#j|1|31</code>

Avec : 
 - #j est obligatoire 
 - 1 correspond au n° de WPT à partir duquel les bombes vont être configurés
 - 31 est le type de bombe. Soit 31, soit 38 (pour les 54, rentrez 38)

En fonction de votre config il est possible que le transfère aille trop vite ou trop lentement, ce qui empêche le programme de fonctionner coorectement. Il est alors possible d'augmenter ou de diminuer le temps lors du transfert des coordonnées en ajoutant à la commande un dernier paramètre : 

<code>#j|1|31|300</code> 

=> il y aura une pause de 300 frames entre 2 transfères (config par défaut)


Le programme fera +1 pour chaque WPT, tant que DCS ne sera pas redémarré. 
Pour le forcer à revenir à 1, il faut ajouter, juste avant le premier 'insert', les caratères ## au niveau de la première ligne de ScratchpadPlus. 

![image](https://github.com/docbrownd/ScratchpadPlus/assets/105074220/aa1a5550-6345-49af-bb9a-9c86730bfcad)





