%% Copyright (c) 2003-2009 Fr????ic Meynadier
%% Original : Eric-Olivier Le Bigot
%% Modifs : Fr????ic Meynadier (Frederic.Meynadier@obspm.fr)
%% Modifs : Dominique Quatravaux (dom@idealx.com) - conversion en
%%     classe de document.
%% 03/01/03
%% Modifs : application d'un patch de Jonas Kahn, 2007-12-19
%% Modifs : anonymisation de l'exemple en commentaire, 2009-02-25
%% Modifs : Sebastien Varrette (Sebastien.Varrette@uni.lu)

%% Permission is hereby granted, free of charge, to any person obtaining a
%% copy of this software and associated documentation files (the
%% "Software"), to deal in the Software without restriction, including
%% without limitation the rights to use, copy, modify, merge, publish,
%% distribute, sublicense, and/or sell copies of the Software, and to
%% permit persons to whom the Software is furnished to do so, subject to
%% the following conditions:

%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.

%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
%% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
%% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
%% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
%% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
%% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cv}
  [2002/01/03 v0.1 Curriculum Vitae package]

\LoadClass[10pt]{article}
\RequirePackage{ifthen}
\RequirePackage{array}

   %%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Mise en page par d??aut %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%

\setlength{\textwidth}{160mm}    %% Largeur de la zone texte
\setlength{\oddsidemargin}{0mm}	 %% Texte centr??sur la page

\pagestyle{empty} % pour ne pas indiquer de num??o de page...

% On d??init les pieds de page comme des \stretch de force 1,
% soit 4 plus fort que celui qui est en bas du chapeau
% (Cf. ci-dessous). De cette fa??n, un CV qui ne remplit pas toute la
% page a un bel espacement.
\makeatletter
\def\@textbottom{\vspace*{\stretch{1}}}
\makeatother


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %      Param??res r??lables          %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L'utilisateur peut les red??inir ceux-ci ?\renewcommand? si besoin :

\newcommand{\espaceInterRubrique}{\medskip\vspace{1em}}

% L'utilisateur peut les red??inir ceux-ci ?\setlength? si besoin :

\newlength{\rubriquetableauparindent} % indentation au d??ut d'une
% ligne de droite dans un ?rubriquetableau?. Cette longueur peut
% ??re n??ative, auquel cas l'alignement dans le tableau se fait
% compte tenu du retrait de la premi??e ligne : celle-ci ne ?bavera?
% pas sur l'espace r??erv??pour la colonne de gauche, au lieu de cela,
% l'ensemble de la colonne de droite est d??al??de l'espace correspondant.

\setlength{\rubriquetableauparindent}{-16pt}


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %     Macros pratiques       %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\def\er{$^{\hbox{er}}$}
\def\ere{$^{\hbox{??e}}$}
\def\eme{$^{\hbox{??e}}$}

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % L'environnement "rubrique" %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Usage : \begin{rubrique}[Indentation]{Titre} [...] \end{rubrique}
% On met le texte qu'on veut ??l'int??ieur.

\newenvironment{rubrique}[1]   % "rubrique" prend un seul argument, le titre
{\espaceInterRubrique\relax%
\noindent\textbf{\large #1}\par%
\noindent\rule[0.5ex]{\textwidth}{0.1mm}\par}{}

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % L'environnement "rubriquetableau" %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Il sert ??rendre les tableaux, avec typiquement des dates ??gauche
% et des activit?? ??droite. Il s'utilise comme ?rubrique?
% ci-dessus, sauf qu'il admet un argument optionnel qui est la largeur
% de la colonne de gauche, et que l'int??ieur doit ??re un tableau
% LaTeX avec les ?&? et les ?\\? qui vont bien.
% Par exemple :
%
% \begin{rubriquetableau}[3.5cm]{pipotage}
% 1999--2000 	& ligne 1\\
% 		& ligne 2\\
% 1998--1999	& ligne 1\\
% [etc...]
% \end{rubriquetableau}
%
% Lorsqu'on omet le param??re entre crochets, cela a pour effet
% de donner la dimension \linewidth ??la premi??e colonne (mais la
% structure reste celle d'un tableau ??deux colonnes, donc ne pas oublier
% d'??rire '\\' pour les retours ??la ligne).

\makeatletter

\newlength{\@cvlenB}\newlength{\@cvlenC}

\newenvironment{rubriquetableau}[2][\linewidth]%% "rubriquetableau"
%						% prend deux arguments
{\bgroup\rubrique{#2}%     % le second argument : titre
\setlength{\@cvlenB}{#1}%  % Le premier argument :indentation
\setlength{\@cvlenC}{\linewidth}%	       % Calculs...
\ifthenelse{\lengthtest{\rubriquetableauparindent<0pt}}
   {\addtolength{\@cvlenC}{\rubriquetableauparindent}}
   {}%
\addtolength{\@cvlenC}{-\@cvlenB}%
\addtolength{\@cvlenC}{-41pt}%
\begin{tabular}[t]{p{\@cvlenB}!{%
   \ifthenelse{\lengthtest{\rubriquetableauparindent<0pt}}
	      {\hspace*{-\rubriquetableauparindent}}
	      {}%
    }>{\setlength{\parindent}{\rubriquetableauparindent}}p{\@cvlenC}}}
{\end{tabular}\egroup}

\makeatother

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %    Le chapeau du CV        %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Usage:
% \begin{chapeau}
% \begin{adresse}
%	Isaac NEWTON\\%
%	9.81, rue des Pommiers\\%
%	Trinity College, Londres\\%
%	\ligne\\%
%	T??. : 06 67 25 90 00\\%
%	E-mail : \texttt{inewton@apple.com}
% \end{adresse}
% \begin{etatcivil}
%	N??le 25/12/1642\\
%	Nationalit??Anglaise
% \end{etatcivil}
% \end{chapeau}

\newenvironment{adresse}{%
\begin{minipage}{0.65\linewidth}
\begin{center}
}
{\end{center}\end{minipage}\hfill}

\newenvironment{etatcivil}{%
\begin{minipage}{0.35\linewidth}
\begin{center}
}
{\end{center}\end{minipage}}

\newcommand{\photo}[1]{\raggedleft\includegraphics[height=8.5em]{#1}}

\newenvironment{chapeau}{%
%\vspace*{-1.5cm}%
\def\ligne{\rule[2pt]{24pt}{1pt}}%
\noindent\begin{minipage}{\linewidth}\hspace{-1cm}%
}
{\end{minipage}\vspace{0.5em}}
