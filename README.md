# ScratchpadPlus
Fork de Scratchpad avec création automatique de WPT

## Installation

L'installation et l'utilisation se fait de la même manière que pour Scratchpad voir ici : https://github.com/rkusa/dcs-scratchpad : copier le dossier Hooks et ScratchpadPlus dans Partie enregistrée/DCS/Scripts

## Lancement
L'ouverture du logiciel se fait par défaut via le raccourci : ctrl+shift+w

## Nouvelle interface (V2.1)

Depuis la version 2.1, l'interface change afin de limiter le nombre de commande à taper (notamment en F15E). De nouveaux systèmes sont disponibles : 

 - Un système permettant d'adapter la vitesse d'appuie à vos paramètres graphiques via une liste déroulante où il vous suffit de choisir le nombre le plus proche de vos FPS. Choisir une valeur légérement au dessus de vos FPS (ctrl droit + pause pour les afficher) (le choix est enregistré automatiquement).
 - Un bouton VR qui activé va empêcher la fenêtre d'enregistrer sa position : si vous l'activer en non VR après avoir positionné la fenêtre au centre, vous vous assurer que la fenêtre ne s'ouvrira jamais en dehors de l'écran en mode VR
 - Pour les pilotes F15E : 
 	- déplacement du bouton Target, qui permet toujours de créer des target point (voir ci-après)
	- ajout d'une liste déroulante permettant de sélectionner à partir de quel WPT les JDAM doivent ête configurées (voir ci-après)
  	- ajout d'une liste déroulante permettant de sélectionner le type d'emport de l'appareil en JDAM, afin de pouvoir les programmer (voir ci-après)
  	- ajout d'un bouton JDAM permettant de programmer les JDAM à partir des paramètres choisis précédemment

![image](https://github.com/docbrownd/ScratchpadPlus/assets/105074220/8551c5aa-4c25-4a58-bfb8-72c8d5e102eb)


## Export des WPT 

Depuis la 1.6, un bouton Export est présent en bas de la fenêtre : il permet d'exporter le contenu de la fenêtre vers un fichier "coordonnees.txt" se trouvant dans le dossier ScratchpadPlus de DCS (dans Partie enregistrées). Il est alors possible de donner ce fichier à d'autres personnes ayant ScratchpadPlus. Pour l'intégrer automatiquement dans l'interface, il suffit de copier le ficheir dans le même dossier et d'utiliser les boutons "précédents/suivants".

## Création de WPT

Lors de la prise d'une coordonnée, une nouvelle ligne commençant par un astérique apparait : c'est la ligne qui sera insérée dans l'ordinateur de bord. 
Si on ne souhaite pas intégrer une coordonnée, il suffit de supprimer l'astérisque.

ATTENTION : s'il existe des WPT, ils seront écrasés


NB : si vous ajoutez une coordonnée dans scratchpad et que vous avez déjà inséré les autres, l'ensemble des coordonnées seront de nouveau insérées dans l'ordinateur de bord, il faut donc soit effacer les coordonnées précédentes, soit retirer l'astérisque


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

  
#### F14 : 

Pour le F14, il n'est pour le moment possible de rentrer qu'au maximun 5 WPT en une fois. De plus, à chaque clique sur insert, les WPT sont (re)créés à partir du WPT n°1. Fonctionne côté Pilote comme RIO


#### F16 : 

- cliquer simplement sur "insert"
- Attention : il n'est possible d'insérer que 20 WPT. Après la manière d'ajouter un WPT change sur le F16 car il s'agit d'autres types de WPT (ex en 25 c'est le BE). Il faudra dont revenir manuellement au WPT 1. 


#### Apache
Les coordonnées seront rentrées au format N 41°55.59' E 044°10.44' 

- Mettre l'écran de droite sur TSD
- choisir dans l'interface le poste : CPG ou Pilote
-  Cliquer sur insert
-  Possible de nommer un WPT de la même manière que pour l'A10

#### Kiowa
Les coordonnées seront rentrées au format N 41°55.59' E 044°10.44' 

- choisir dans l'interface le poste : CPG ou Pilote
-  Cliquer sur insert


  ##

#### F15E

Phase de TEST, le fonctionnement décrit ci-après peut fortement changer à court terme. 

Pour le F15E, le programme fonctionne différemment du fait que la création de WPT dans cet appareil est particulier. En effet il est nécessaire de saisir manuellement le numro du WPT à créer (impossible de faire +1) et pour avoir un WPT d'attaque, il faut créer des targets points (numéro de WPT suivi d'un point). Hors en cas de présence d'un target point, il n'est plus possible d'éditer le WPT (sans numéro) initial, car il n'existe plus. 

Ces différentes contraintes expliquent le fonctionnement suivant : 

- faites un 'clear' du logiciel => obligatoire !
- prennez vos WPT comme d'habitude
- Placez vous sur la page n°1 du  menu (cf image ci-après)
- Cliquer sur insert

Le programme va alors :
 - insérer les WPT en partant de 1 ~~et les modifier en target point~~ (non valable à partir de la 1.3)
 - utiliser le canal B afin de conserver toute route qui serait créées dans A (ATTENTION : B ne doit donc pas être utilisé)
 - A partir de la version 1.3 : si un point est ajouté manuellement entre * et | alors le WPT sera transformé en Target Point. (ex *.|N 41°55.590'|E 044°10.440'|3140|1 => le WPT 1B sera converti en 1.B)
 - A partir de la version 1.5 : si les caractères #. sont ajoutés en haut de la fenêtre, alors l'ensemble des waypoints seront convertis en target point
 - A partir de la 1.7, un bouton "target" est disponible : il insert les WPT dans le F15 et les convertis en TargetPoint. 

 ### F15E et JDAM

A partir de la version 1.9, il est possible, sous certaines conditions, d'assigner automatiquement un waypoint à une bombe. Pour cela il faut avoir les bons paramètres (attention, cela va forcément changer suite aux maj à venir des JDAM): 
 - les coordonnées sont rentrées au format target point et dans la route B
 - l'UFC est sur la première page de Menu (avec LAW en PB1)
 - le programme de larguage est configuré correctement (en cas d'emport mixte, ne pas oublier de switcher de programme pour passer des GBU31 à 38 par exemple)
 - l'avion est en mode A/G 
 - le MFD de droite est sur la page SMART WPT et la première bombe est sélectionnée (L1 si bombe sur CTF, pylone du centre dans le cas contraire)
   
Au niveau de l'interface (à partir de la 2.1) : 
 - Sélectionner le WPT à partir duquel il faudra commencer la programmation des bombes
 - choisissez votre configuration d'emport : 3/4/5/7 GBU31 ou 6/9 GBU38 (marche aussi avec des GBU54). Attention à bien respecter la position des emports : 
	- 3 GBU31 => sous les ailes et le pylône central 
	- 4 GBU31 => sur les CFT
	- 5 GBU31 => sur les CTF + pylône central
 	- 7 GBU31 => l'ensemble des pylônes 
	- 6 GBU38 =>  sur les CFT
	- 9 GBU38 => l'ensemble des pylônes 
 - cliquer sur le bouton JDAM



Le programme fera +1 pour chaque WPT, tant que DCS ne sera pas redémarré. 
Pour le forcer à revenir à 1, il faut ajouter, juste avant le premier 'insert', les caratères ## au niveau de la première ligne de ScratchpadPlus. 

![image](https://github.com/docbrownd/ScratchpadPlus/assets/105074220/aa1a5550-6345-49af-bb9a-9c86730bfcad)





