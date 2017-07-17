program Biblioteca1;

uses 	sysutils,crt;

const

   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
       {rutas de los archivos, por ahora son constates}

       DIRTITULOS=('Titulos.dat');
       DIRAUTORES=('Autores.dat');
       DIRGENEROS=('Generos.dat');
       DIREJEMPLARES=('Ejemplares.dat');
       DIRSOCIOS=('Socios.dat');
       DIRPRESTAMOS=('Prestamos.dat');


   {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}

       MAX_PASILLOS=10;
       MAX_ESTANTES=15;
       MAX_GENERO=7;
       MAX_INDICE=250;

type

        t_nombre=string[20];


        type tr_indice= record
                clave: integer;
                pos: longint;
                end;


        t_indice=record
           v_indice:array [1..MAX_INDICE] of tr_indice;
           cantidad:0..MAX_INDICE;
        End;


	{DEFINIMOS TODOS LOS REGISTROS QUE VAMOS A USAR}

	tr_ubicacion=record
		pasillo:1..MAX_PASILLOS;
		estante:1..MAX_ESTANTES;
	end;

	tr_genero=record
		numero:byte;
		nombre:t_nombre;
		ubicacion_desde:tr_ubicacion;
		ubicacion_hasta:tr_ubicacion;
                baja:boolean;
	end;

	tr_autor=record
		numero:integer;
		nombre:t_nombre;
                esta:boolean;
	end;

	tr_titulos=record
		numero:integer;
		nombre:t_nombre;
		numero_autor:integer;
		numero_genero:byte;
                esta:boolean;
	end;

	tr_ejemplar=record
		numero:integer;
		numero_titulo:integer;
		pasillo:1..MAX_PASILLOS;
		estante:1..MAX_ESTANTES;
                esta:boolean;
                prestamo:boolean;
                dia:byte;
	end;

   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
   {defino el tipo socio}

        tr_socio=record
                numero:integer;
                nombre:t_nombre;
                dni:string[15];
                direccion:string[30];
                esta:boolean;
        end;
   {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}

        tr_prestamo=record
                num_ejemplar:integer;
                num_socio:integer;
                fecha:longint;
                esta:boolean;
        end;

   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
   {defino los tipos de archivos}

   tar_titulos=file of tr_titulos;
   tar_autores=file of tr_autor;
   tar_generos=file of tr_genero;
   tar_ejemplares=file of tr_ejemplar;
   tar_socios=file of tr_socio;
   tar_prestamos=file of tr_prestamo;


   {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}

var

   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
         {definicion de los archivos como variables}

     artitulos:tar_titulos;  {archivo de titulos}
     arautores:tar_autores;  {archivo de autores}
     argeneros:tar_generos;  {archivo con generos}
     arejemplares:tar_ejemplares;  {archivo con generos (provisorio)}
     arsocios:tar_socios;          {archivo de socios}
     arprestamos:tar_prestamos;
     fecha:longint;

     indice_autores:t_indice;


procedure intercambio (var a,b:tr_indice);
var aux: tr_indice;
begin
 aux:=a;
 a:=b;
 b:=aux;
end;


procedure ordenar_indice (var indice: t_indice);

  var
        i,j:integer;
        desordenado:boolean;

  begin

    desordenado:= true;
    i:=1;

    while ((desordenado) and (i<= (indice.cantidad-1))) do

    begin
      desordenado:= false;
      for j:=1 to (indice.cantidad-i) do
        if indice.v_indice[j].clave>indice.v_indice[j+1].clave then
          begin
            intercambio (indice.v_indice[j],indice.v_indice[j+1]);
            desordenado:= true;
      end;
    inc (i);
   end;
end;

procedure armar_ind_autores(var arautores:tar_autores;
                             var indice:t_indice);

var autor:tr_autor;

begin
  reset (arautores);

  indice.cantidad:=0;

  while not eof (arautores) do
       begin
            read (arautores,autor);
            inc (indice.cantidad);
            indice.v_indice[indice.cantidad].clave:= autor.numero;
            indice.v_indice[indice.cantidad].pos:= filepos(arautores)-1;
       end;
end;

function busqueda_clave (var indice:t_indice;clave:integer):longint;
{busca en el indice y devuelve la pocision de una clave dentro
 del archivo}
var
    primero,ultimo,central: integer;
    encontrado: boolean;
begin

  primero:= 1;
  ultimo:= indice.cantidad;
  encontrado:= false;


  while ((not encontrado) and (primero<=ultimo)) do
   begin
     central:= (primero+ultimo) div 2;
     if indice.v_indice[central].clave=clave then
       begin
        busqueda_clave:= indice.v_indice[central].pos;
        encontrado:= true;
       end
     else
       if clave>indice.v_indice[central].clave then primero:= central +1
       else ultimo:= central -1;

   end;

   if not encontrado then
   busqueda_clave:= -1;

end;


   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
              {CARGA LA FECHA DE LA MAQUINA}

Procedure cargar_fecha_sistema(var fecha:longint);
{carga la variable fecha con la fecha de hoy
con el formato AAAAMMDD}
var
  dia,mes,annio:word;
  hoy:TdateTime;
begin
  hoy:=now;
  Decodedate(hoy,annio,mes,dia);
  fecha:=((annio*10000)+(mes*100)+dia);
end;


   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

 {INICILIZA LOS GENEROS COLOCANDOLE LOS 7 NOMBRES DADOS EN EL ENUNCIADO}

Procedure Ini_Generos(var argeneros:tar_generos);

const
   NOVELA=1;
   ENSAYO=2;
   CIENCIA=3;
   HUMANIDADES=4;
   INFANTIL=5;
   DICCIONARIO=6;
   OTROS=7;

type
   tvector=array[1..MAX_GENERO] of tr_genero;

var
   contpasillos,iniciopasillo:integer;
   contestantes,inicioestante:integer;
   totalestantes,estantesrecorridos,contgenero,i:integer;
   generos:tvector;

begin

  reset(argeneros);
  {cantgeneros:=7;}
  totalestantes:=(MAX_PASILLOS * MAX_ESTANTES);{cantidad de estantes de la
biblioteca}

  estantesrecorridos:=0;
  contestantes:=0;
  iniciopasillo:=1;
  inicioestante:=1;
  contgenero:=0;

  for contpasillos:=1 to MAX_PASILLOS do
      for contestantes:=1 to MAX_ESTANTES do{recorro toda la biblioteca}

        begin
         {divide a la biblioteca en cantidad de estantes iguales
         y asigna los generos}
           INC(estantesrecorridos);{cantidad de estantes recorridos}

          if ((estantesrecorridos mod MAX_GENERO)=0) and (contgenero<=MAX_GENERO-1) then
             begin
              Inc(contgenero);

              generos[contgenero].numero:=contgenero;
              generos[contgenero].ubicacion_desde.pasillo:=iniciopasillo;
              generos[contgenero].ubicacion_desde.estante:=inicioestante;
              generos[contgenero].ubicacion_hasta.pasillo:=contpasillos;
              generos[contgenero].ubicacion_hasta.estante:=contestantes;

              {inicioestante:=contestantes + 1;}

              if inicioestante>contestantes then
              begin
                inc(iniciopasillo);

                inicioestante:=contestantes + 1;
              end
              else
                inicioestante:=contestantes + 1;

             end;
         end;

  {pone los nombres de los generos segun las constantes que declare antes}
  generos[NOVELA].nombre:='Novela';
  generos[ENSAYO].nombre:='Ensayo';
  generos[CIENCIA].nombre:='Ciencia';
  generos[HUMANIDADES].nombre:='Humanidades';
  generos[INFANTIL].nombre:='Infantil';
  generos[DICCIONARIO].nombre:='Diccionario';
  generos[OTROS].nombre:='Otros';

  for i:=1 to MAX_GENERO do
     write(argeneros,generos[i]);

end;

{****************************************************************************}

   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

              {INICIALIZA LOS ARCHIVOS}
{se le pasan como variables los 5 tipos de archivos y sus rutas}

Procedure Ini_Archivos(var artitulos:tar_titulos;var arautores:tar_autores;
                       var argeneros:tar_generos;var arejemplares:tar_ejemplares;
                       var arsocios:tar_socios;var arprestamos:tar_prestamos;
                       titulosdir,autoresdir,prestamosdir,generosdir,
                       ejemplaresdir,sociosdir:string[50]);

begin
{asignacion de variables}

Assign(artitulos,titulosdir);
Assign(arautores,autoresdir);
Assign(argeneros,generosdir);
Assign(arejemplares,ejemplaresdir);
Assign(arsocios,sociosdir);
Assign(arprestamos,prestamosdir);

{$I-}{desactiva los errores}

{Apertura de archivos}

{si ya existe pone el puntero en la primera posicion,
si no existe crea el archivo}

reset(artitulos);
if ioresult<>0 then rewrite(artitulos);

reset(arautores);
if ioresult<>0 then rewrite(arautores);

reset(argeneros);
if ioresult<>0 then
begin
   rewrite(argeneros);
   ini_generos(argeneros)
end;

reset(arejemplares);
if ioresult<>0 then rewrite(arejemplares);

reset(arsocios);
if ioresult<>0 then rewrite(arsocios);

reset(arprestamos);
if ioresult<>0 then rewrite(arprestamos);

{$I+}{vuelve a activar errores}
end;

    {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}


    {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
              {Cierra los archivos}

      {Hay que acordarse de actualizarlos antes}

Procedure Cerrar_Archivos(var artitulos:tar_titulos;var arautores:tar_autores;
                          var argeneros:tar_generos;var arejemplares:tar_ejemplares;
                          var arsocios:tar_socios;var arprestamos:tar_prestamos);

  begin
      Close(artitulos);
      Close(arautores);
      Close(argeneros);
      Close(arejemplares);
      Close(arsocios);
      Close(arprestamos);
  end;
    {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}

{****************************************************************************}

         {********************************************************}
         {********************************************************}

                          {FUNCIONES SOBRE AUTORES}

         {********************************************************}
         {********************************************************}

function buscar_autor_numero(var arch:tar_autores;numautor:integer;ind_autores:t_indice):tr_autor;

       {se le pasa un numero de autor y devuelve el tr_autor correspondiente
, si no existe ningun autor con ese numero devuelve un tr_autor con numero 0}

var     autortemp:tr_autor;
        posautor:longint;

begin

        autortemp.esta:=false;


        {carga los datos del autor solo si este esta en la biblioteca}

        posautor:=busqueda_clave(ind_autores,numautor);


        if posautor<>-1 then
         begin
          seek(arch,posautor);
          read(arch,autortemp);
         end;
        {devuelve el resultado}

        if not autortemp.esta then
           autortemp.numero:=0;

        Buscar_Autor_numero:= autortemp;

end;

         {********************************************************}

function buscar_autor_nombre(var arch:tar_autores; nombre:t_nombre):integer;

{se le pasa como parametros un nombre de autor y devuelve su numero, si no
esta devuleve 0, si esta devuelve su numero}

var
   autortemp:tr_autor;
   encontrado:boolean;

begin
        reset(arch);
        encontrado:=false;

        {recorre el archivo hasta encontrar el nombre}

        While (not eof(arch)) and (not encontrado) do
        begin
            read(arch,autortemp);
            encontrado:=(nombre=autortemp.nombre) and (autortemp.esta);
        end;

        If encontrado then buscar_autor_nombre:=autortemp.numero
        else buscar_autor_nombre:=0;

end;

         {********************************************************}

Function Buscar_lugar_autor (var arch:tar_autores):integer;
     {devuelve la primera posicion libre en el archivo}

var
   autortemp:tr_autor;
   encontrado:boolean;
   contador:integer;
begin
   reset(arch);
   contador:=-1;
   encontrado:=false;

while (not eof(arch)) and (not encontrado) do
begin
	read(arch,autortemp);
	encontrado:= not(autortemp.esta);
	Inc(contador);
end;

if encontrado then
        Buscar_lugar_autor:=contador
else Buscar_lugar_autor:=filesize(arch);

end;

        {********************************************************}

function sacar_autor(var arch:tar_autores;nombre:t_nombre):boolean;

{se le pasa un nombre de autor, si esta lo retira del archivo y devuelve
true de lo contrario devuelve false.}

var
  autortemp:tr_autor;
  numautor:integer;
  sacado:boolean;

begin

  sacado:=false;
  numautor:=buscar_autor_nombre(arch,nombre);

  if numautor>0 then
        begin
         seek(arch,numautor-1);
         read(arch,autortemp);

         if autortemp.esta then
                begin
                  autortemp.esta:=false;
                  seek(arch,numautor-1);
                  write(arch,autortemp);
                  sacado:=true;
                end;
        end;
sacar_autor:=sacado;

end;

        {********************************************************}


function insertar_autor(var arch:tar_autores;autor:tr_autor;var ind_autores:t_indice):boolean;
{recibe el tr_autor que se quiere ingresar y devuelve true si se logro
insertar porque no existia o false en caso contrario}

var

    insertado:boolean;
    autortemp:tr_autor;
    pos,numautor:integer;

begin

  insertado:=false;
  numautor:=buscar_autor_nombre(arch,autor.nombre);

  if numautor=0 then
        begin
         pos:=buscar_lugar_autor(arch);
         autor.numero:=pos+1;
         autor.esta:=true;
         seek(arch,pos);
         write(arch,autor);
         insertado:=true;
        end;

  inc(ind_autores.cantidad);
  ind_autores.v_indice[ind_autores.cantidad].clave:=pos+1;
  ind_autores.v_indice[ind_autores.cantidad].pos:=pos;
  ordenar_indice(ind_autores);

  insertar_autor:=insertado;

end;

         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

procedure tabla_autores;
begin
writeln ('----------Autores-----------|');
writeln ('Numero|        Nombre       |');
writeln ('----------------------------|');
end;


         {********************************************************}
         {********************************************************}

                       {FUNCIONES SOBRE TITULOS}

         {********************************************************}
         {********************************************************}

function buscar_titulo_numero(var arch:tar_titulos;numtitulo:integer)
                              :tr_titulos;

       {se le pasa un numero de titulo y devuelve el tr_titulo
correspondiente, si no existe ningun titulo con ese numero devuelve
un tr_titulo con numero 0}

var     tittemp:tr_titulos;

begin
        tittemp.esta:=false;

        {carga los datos del autor solo si este esta en la biblioteca}

        if (numtitulo<=filesize(arch)) and (numtitulo>0) then
        begin
           seek(arch,numtitulo-1);
           read(arch,tittemp);
        end;

        {devuelve el resultado}

        if not tittemp.esta then
           tittemp.numero:=0;

        Buscar_titulo_numero:= tittemp;

end;

         {********************************************************}

function buscar_titulo_nombre(var arch:tar_titulos;nombre:t_nombre):integer;

{se le pasa como parametros un nombre de titulo y devuelve su numero, si no
esta devuleve 0, si esta devuelve su numero}

var
   tittemp:tr_titulos;
   encontrado:boolean;

begin
        reset(arch);
        encontrado:=false;

        {recorre el archivo hasta encontrar el nombre}

        While (not eof(arch)) and (not encontrado) do
        begin
            read(arch,tittemp);
            encontrado:=(nombre=tittemp.nombre) and (tittemp.esta);
        end;

        If encontrado then buscar_titulo_nombre:=tittemp.numero
        else buscar_titulo_nombre:=0;

end;

         {********************************************************}

Function Buscar_lugar_titulo (var arch:tar_titulos):integer;
     {devuelve la primera posicion libre en el archivo}

var
   tittemp:tr_titulos;
   encontrado:boolean;
   contador:integer;
begin
   reset(arch);
   contador:=-1;
   encontrado:=false;

while (not eof(arch)) and (not encontrado) do
begin
	read(arch,tittemp);
	encontrado:= not(tittemp.esta);
	Inc(contador);
end;

if encontrado then
        Buscar_lugar_titulo:=contador
else Buscar_lugar_titulo:=filesize(arch);

end;

        {********************************************************}

function sacar_titulo(var arch:tar_titulos;nombre:t_nombre):boolean;

{se le pasa un nombre de titulo, si esta lo retira del archivo y devuelve
true
de lo contrario devuelve false.}

var
  tittemp:tr_titulos;
  numtitulo:integer;
  sacado:boolean;

begin

  sacado:=false;
  numtitulo:=buscar_titulo_nombre(arch,nombre);

  if numtitulo>0 then
        begin
         seek(arch,numtitulo-1);
         read(arch,tittemp);

         if tittemp.esta then
                begin
                  tittemp.esta:=false;
                  seek(arch,numtitulo-1);
                  write(arch,tittemp);
                  sacado:=true;
                end;
        end;
sacar_titulo:=sacado;

end;

        {********************************************************}


function insertar_titulo(var arch:tar_titulos;titulo:tr_titulos):boolean;
{recibe el tr_titulo que se quiere ingresar y devuelve true si se logro
insertar porque no existia o false en caso contrario}

var

    insertado:boolean;
    tittemp:tr_titulos;
    pos,numtitulo:integer;

begin

  insertado:=false;
  numtitulo:=buscar_titulo_nombre(arch,titulo.nombre);

  if numtitulo=0 then
        begin
         pos:=buscar_lugar_titulo(arch);
         titulo.numero:=pos+1;
         titulo.esta:=true;
         seek(arch,pos);
         write(arch,titulo);
         insertado:=true;
        end;

  insertar_titulo:=insertado;

end;

          {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

procedure tabla_titulos;
begin
writeln ('----------------------------------Titulos-------------------------------');
writeln ('Numero de titulo|  Nombre de titulo  |Numero de autor| Numero de genero|');
writeln ('----------------|--------------------|---------------|-----------------|');
end;

          {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

procedure escribir_dato_titulo (titulo: tr_titulos);
begin
writeln ('Nombre de titulo: ', titulo.nombre);
writeln ('Numero de titulo: ', titulo.numero);
writeln ('Numero de genero: ', titulo.numero_genero);
writeln;
end;

         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

function buscar_numautor_titulos (var archtitulos:tar_titulos;
                                  codigo:integer):boolean;
      var
         titulo_reg:tr_titulos;
         encontrado:boolean;
      begin
           reset(archtitulos);
           encontrado:=false;
           while (not eof(archtitulos)) and (not encontrado) do
           begin
                read(archtitulos,titulo_reg);
                if (codigo=titulo_reg.numero_autor) and (titulo_reg.esta) then
                   encontrado:= true;
           end;
           buscar_numautor_titulos:=encontrado;
      end;


         {********************************************************}
         {********************************************************}

                        {FUNCIONES SOBRE SOCIOS}

         {********************************************************}
         {********************************************************}

function buscar_socio_numero(var arch:tar_socios;numsocio:integer):tr_socio;

       {se le pasa un numero de socio y devuelve el tr_socio
correspondiente, si
       no existe ningun socio con ese numero devuelve un tr_socio con numero
0}

var     sociotemp:tr_socio;

begin
        sociotemp.esta:=false;

        {carga los datos del autor solo si este esta en la biblioteca}

        if (numsocio<=filesize(arch)) and (numsocio>0) then
        begin
           seek(arch,numsocio-1);
           read(arch,sociotemp);
        end;

        {devuelve el resultado}

        if not sociotemp.esta then
           sociotemp.numero:=0;

        Buscar_socio_numero:= sociotemp;

end;

         {********************************************************}

function buscar_socio_nombre(var arch:tar_socios;nombre:t_nombre):integer;

{se le pasa como parametros un nombre de socio y devuelve su numero, si no
esta devuleve 0, si esta devuelve su numero}

var
   sociotemp:tr_socio;
   encontrado:boolean;

begin
        reset(arch);
        encontrado:=false;

        {recorre el archivo hasta encontrar el nombre}

        While (not eof(arch)) and (not encontrado) do
        begin
            read(arch,sociotemp);
            encontrado:=(nombre=sociotemp.nombre) and (sociotemp.esta);
        end;

        If encontrado then buscar_socio_nombre:=sociotemp.numero
        else buscar_socio_nombre:=0;

end;

         {********************************************************}

Function Buscar_lugar_socio (var arch:tar_socios):integer;
     {devuelve la primera posicion libre en el archivo}

var
   sociotemp:tr_socio;
   encontrado:boolean;
   contador:integer;
begin
   reset(arch);
   contador:=-1;
   encontrado:=false;

while (not eof(arch)) and (not encontrado) do
begin
	read(arch,sociotemp);
	encontrado:= not(sociotemp.esta);
	Inc(contador);
end;

if encontrado then
        Buscar_lugar_socio:=contador
else Buscar_lugar_socio
:=filesize(arch);

end;

        {********************************************************}

function sacar_socio(var arch:tar_socios;nombre:t_nombre):boolean;

{se le pasa un nombre de socio, si esta lo retira del archivo y devuelve
true
de lo contrario devuelve false.}

var
  sociotemp:tr_socio;
  numsocio:integer;
  sacado:boolean;

begin

  sacado:=false;
  numsocio:=buscar_socio_nombre(arch,nombre);

  if numsocio>0 then
        begin

         seek(arch,numsocio-1);
         read(arch,sociotemp);

         if sociotemp.esta then
                begin
                  sociotemp.esta:=false;
                  seek(arch,numsocio-1);
                  write(arch,sociotemp);
                  sacado:=true;
                end;
        end;
sacar_socio:=sacado;

end;

        {********************************************************}


function insertar_socio(var arch:tar_socios;socio:tr_socio):boolean;
{recibe el tr_socio que se quiere ingresar y devuelve true si se logro
insertar porque no existia o false en caso contrario}

var

    insertado:boolean;
    sociotemp:tr_socio;
    pos,numsocio:integer;

begin

  insertado:=false;
  numsocio:=buscar_socio_nombre(arch,socio.nombre);

  if numsocio=0 then
        begin
         pos:=buscar_lugar_socio(arch);
         socio.numero:=pos+1;
         socio.esta:=true;
         seek(arch,pos);
         write(arch,socio);
         insertado:=true;
        end;

  insertar_socio:=insertado;

end;



         {********************************************************}
         {********************************************************}

                        {FUNCIONES SOBRE EJEMPLARES}

         {********************************************************}
         {********************************************************}


function buscar_ejemplar_numero(var arch:tar_ejemplares;numejemplar:integer)
                                :tr_ejemplar;

       {se le pasa un numero de ejemplar y devuelve el tr_ejemplar
correspondiente, si
       no existe ningun ejemplar con ese numero devuelve un tr_ejemplar con
numero 0}

var     ejemplartemp:tr_ejemplar;

begin
        ejemplartemp.esta:=false;

        {carga los datos del autor solo si este esta en la biblioteca}

        if (numejemplar<=filesize(arch)) and (numejemplar>0) then
        begin
           seek(arch,numejemplar-1);
           read(arch,ejemplartemp);
        end;

        {devuelve el resultado}

        if not ejemplartemp.esta then
           ejemplartemp.numero:=0;

        Buscar_ejemplar_numero:= ejemplartemp;

end;

         {********************************************************}
         {********************************************************}

Function Buscar_lugar_ejemplar (var arch:tar_ejemplares):integer;
     {devuelve la primera posicion libre en el archivo}

var
   ejemplartemp:tr_ejemplar;
   encontrado:boolean;
   contador:integer;
begin
   reset(arch);
   contador:=-1;
   encontrado:=false;

while (not eof(arch)) and (not encontrado) do
begin
	read(arch,ejemplartemp);
	encontrado:= not(ejemplartemp.esta);
	Inc(contador);
end;

if encontrado then
        Buscar_lugar_ejemplar:=contador
else Buscar_lugar_ejemplar:=filesize(arch);

end;

        {********************************************************}

function sacar_ejemplar(var arch:tar_ejemplares;numero:integer):boolean;

{se le pasa un numero de ejemplar, si esta lo retira del archivo y devuelve
true
de lo contrario devuelve false.}

var
  ejemplartemp:tr_ejemplar;
  sacado:boolean;

begin

  sacado:=false;

  ejemplartemp:=buscar_ejemplar_numero(arch,numero);

  if ejemplartemp.numero>0 then
        begin

         seek(arch,numero-1);
         read(arch,ejemplartemp);

         if ejemplartemp.esta then
                begin
                  ejemplartemp.esta:=false;
                  seek(arch,numero-1);
                  write(arch,ejemplartemp);
                  sacado:=true;
                end;
        end;
sacar_ejemplar:=sacado;

end;

        {********************************************************}


function insertar_ejemplar(var arch:tar_ejemplares;ejemplar:tr_ejemplar):boolean;
{recibe el tr_ejemplar que se quiere ingresar y devuelve true si se logro
insertar porque no existia o false en caso contrario}

var

    insertado:boolean;
    ejemplartemp:tr_ejemplar;
    pos,numejemplar:integer;

begin

  insertado:=false;
  ejemplartemp:=Buscar_ejemplar_numero(arch,ejemplar.numero);

  if ejemplartemp.numero=0 then
        begin
         pos:=buscar_lugar_ejemplar(arch);
         ejemplar.numero:=pos+1;
         ejemplar.esta:=true;
         seek(arch,pos);
         write(arch,ejemplar);
         insertado:=true;
        end;

  insertar_ejemplar:=insertado;

end;

         {********************************************************}

function buscar_numtitulo_ejemplares(var archejemplar:tar_ejemplares;
                                             codigo:integer):boolean;
     var
     	ejemplar_reg:tr_ejemplar;
     	encontrado:boolean;

     begin
        reset(archejemplar);
     	encontrado:=false;
     	while (not eof(archejemplar)) and (not encontrado) do
     	begin
     		read(archejemplar,ejemplar_reg);
     		if (codigo=ejemplar_reg.numero_titulo) and (ejemplar_reg.esta) then
     			encontrado:=true;
     	end;
     	buscar_numtitulo_ejemplares:=encontrado;
     end;


         {********************************************************}
         {********************************************************}

                         {FUNCIONES SOBRE GENEROS}

         {********************************************************}
         {********************************************************}

                 {solo se puede leer info de ellos}


function buscar_genero_numero(var
arch:tar_generos;numgenero:integer):tr_genero;

       {se le pasa un numero de autor y devuelve el tr_genero
correspondiente, si
       no existe ningun autor con ese numero devuelve un tr_autor con numero
0}

var     generotemp:tr_genero;

begin

        generotemp.numero:=0;
        {carga los datos del genero solo si este esta en la biblioteca}

        if (numgenero<=filesize(arch)) and (numgenero>0) then
        begin
           seek(arch,numgenero-1);
           read(arch,generotemp);
        end;


        Buscar_genero_numero:= generotemp;

end;

         {********************************************************}

function buscar_genero_nombre(var arch:tar_generos;nombre:t_nombre):integer;

{se le pasa como parametros un nombre de genero y devuelve su numero, si no
esta devuleve 0, si esta devuelve su numero}

var
   generotemp:tr_genero;
   encontrado:boolean;

begin
        reset(arch);
        encontrado:=false;

        {recorre el archivo hasta encontrar el nombre}

        While (not eof(arch)) and (not encontrado) do
        begin
            read(arch,generotemp);
            encontrado:=(nombre=generotemp.nombre);
        end;

        If encontrado then buscar_genero_nombre:=generotemp.numero
        else buscar_genero_nombre:=0;

end;

         {********************************************************}
         {********************************************************}

                        {FUNCIONES SOBRE PRêSTAMOS}

         {********************************************************}
         {********************************************************}

function pos_fis_prestamo(var arprestamos:tar_prestamos;
                          numejemplar:integer):longint;
{se le pasa un numero de ejemplar y devuelve la posicion fisica del prestamo
de ese ejemplar en el archivo prestamos, si no existe devuelve -1}

   var
        encontrado:boolean;
        contador:longint;
        prestamotemp:tr_prestamo;
   begin
     encontrado:=false;
     contador:=-1;
     reset(arprestamos);

     while (not eof(arprestamos)) and (not encontrado) do
        begin
          Inc(contador);
          read(arprestamos,prestamotemp);
          encontrado:=(prestamotemp.num_ejemplar=numejemplar) and
                      (prestamotemp.esta);

        end;

        if not encontrado then pos_fis_prestamo:=-1 else
                pos_fis_prestamo:=contador;
   end;

         {********************************************************}

Function buscar_lugar_prestamo(var arch:tar_prestamos):longint;
   {busca el primer lugar donde ubicar un registro de
   prestamo dentro del archivo}
   var
        prestamotemp:tr_prestamo;
        encontrado:boolean;
        contador:integer;

   begin
        reset(arch);
        contador:=-1;
        encontrado:=false;

        while (not eof(arch)) and (not encontrado) do
            begin
	      read(arch,prestamotemp);
	        encontrado:= not(prestamotemp.esta);
	        Inc(contador);
            end;

        if encontrado then
        Buscar_lugar_prestamo:=contador
        else Buscar_lugar_prestamo:=filesize(arch);

   end;

         {********************************************************}

function buscar_numsocio_prestamos(var archprestamo:tar_prestamos;
                                   codigo:integer):boolean;
    var
     	prestamo_reg:tr_prestamo;
     	encontrado:boolean;
     begin
        reset(archprestamo);
     	encontrado:=false;
     	while (not eof(archprestamo)) and (not encontrado) do
     	begin
     		read(archprestamo,prestamo_reg);
     		if (codigo=prestamo_reg.num_socio) and (prestamo_reg.esta) then
     			encontrado:=true;
     	end;
     	buscar_numsocio_prestamos:=encontrado;
     end;


         {********************************************************}
         {********************************************************}

     {CARTEL DE PRESIONE CUALQUIER TECLA PARA VOLVER AL MENÈ PRINCIPAL}

procedure mensaje(renglon1,renglon2:string);
begin
   gotoxy(17,7);
   textbackground(red);
   writeln('************************************************');
   gotoxy(17,8);
   writeln('*                                              *');
   gotoxy(17,9);
   writeln('*         ',renglon1,                 '        *');
   gotoxy(17,10);
   writeln('*         ',renglon2,                 '        *');
   gotoxy(17,11);
   writeln('*                                              *');
   gotoxy(17,12);
   writeln('************************************************');
   textbackground(black);
end;

         {********************************************************}

                 {DIBUJO DEL MAPA GENERAL DE LA BIBLIOTECA}

procedure dibujar_mapa;

var i:byte;

begin
   writeln   (' _____   _____   _____   _____   _____   _____   _____   _____   _____   _____ ');

   for i:=1 to 15 do
   begin
      gotoxy(1,i+1);
      writeln('|_____| |_____| |_____| |_____| |_____| |_____| |_____| |_____| |_____| |_____|');
   end;
end;

         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

function quiere_continuar: boolean;
const espacio= ' ';
      esc=#27;
var car: char;
    continuar: boolean;
begin
           repeat
           writeln;
           writeln ('Si desea continuar presione la barra espaciadora');
           writeln ('En caso contrario presione ESC');
           writeln;
           car:= readkey;
           until  (car = espacio) or (car = esc);
           if (car=espacio) then continuar:=true
           else continuar:= false;
           quiere_continuar:= continuar;
end;

        {********************************************************}

                {MENU DINAMICO UTILIZADO COMO UN SUBMENU}

procedure menu_dinam(boton1,boton2,boton3:string);

var     i,j:integer;

begin
   clrscr;
   j:=0;
   gotoxy(9,10);

   for i:=10 downto 1 do
   begin
      textbackground(black);
      clrscr;
      gotoxy(i,10-j);
      textbackground(white);
      textcolor(blue);
      write(' 1 ');
      textbackground(red);
      textcolor(white);
      write(boton1);
      delay(30);
      textbackground(black);
      write(' ');
      inc(j);
   end;

   j:=0;
   gotoxy(9,10);

   for i:=9 to 18 do
   begin
      textbackground(black);
      gotoxy(1,1);
      textbackground(white);
      textcolor(blue);
      write(' 1 ');
      textbackground(red);
      textcolor(white);
      write(boton1);
      gotoxy(i,10-j);
      textbackground(white);
      textcolor(blue);
      write(' 2 ');
      textbackground(red);
      textcolor(white);
      write(boton2);
      delay(30);
      textbackground(black);
      gotoxy(i-1,(10-j)+1);
      write('                    ');
      inc(j);
   end;

   j:=0;
   gotoxy(21,10);

   for i:=21 to 30 do
   begin
      textbackground(black);
      gotoxy(1,1);
      textbackground(white);
      textcolor(blue);
      write(' 1 ');
      textbackground(red);
      textcolor(white);
      write(boton1);
      gotoxy(18,1);
      textbackground(white);
      textcolor(blue);
      write(' 2 ');
      textbackground(red);
      textcolor(white);
      write(boton2);
      gotoxy(i,10-j);
      textbackground(white);
      textcolor(blue);
      write(' 3 ');
      textbackground(red);
      textcolor(white);
      write(boton3);
      delay(30);
      textbackground(black);
      gotoxy(i-1,(10-j)+1);
      write('                             ');
      inc(j);
   end;
end;

         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

          {******************************************************}

function Ver_Ubicacion(numestante:integer):tr_ubicacion;
  {se le pasa un numero de estante y devuelve su pocision
  pasillo-estante}

   var
      ubitemp:tr_ubicacion;
   begin

         if (numestante mod 15)=0 then
            ubitemp.pasillo:=(numestante div 15)
          else ubitemp.pasillo:=(numestante div 15)+1;
          ubitemp.estante:=(numestante-(15*ubitemp.pasillo)+15);

   Ver_Ubicacion:=ubitemp;

   end;


   {*****************************************************************}

   {*****************************************************************}

Procedure mover_estante(var erejemplares:tar_ejemplares;desdepasillo,
                        desdeestante,hastapasillo,hastaestante:byte);
{mueve todos los ejemplares de un estante a otro}
var
   ejemplartemp:tr_ejemplar;

begin
   reset(arejemplares);

   while not eof(arejemplares) do

                begin
                 read(arejemplares,ejemplartemp);

                 if (ejemplartemp.pasillo=desdepasillo) and
                    (ejemplartemp.estante=desdeestante) then

                    begin
                      ejemplartemp.pasillo:=hastapasillo;
                      ejemplartemp.estante:=hastaestante;
                      seek(arejemplares,filepos(arejemplares)-1);
                      write(arejemplares,ejemplartemp);
                    end;
                end;
end;

        {********************************************************}


Function pos_fis_ejemplar(var arjemplares:tar_ejemplares;numejemplar:longint)
                          :longint;

{se le pasa un numero de ejemplar y devuelve su posicion fisica en el
archivo, si no existe devuelve -1}

   var
        encontrado:boolean;
        contador:longint;
        ejemplartemp:tr_ejemplar;
   begin
     encontrado:=false;
     contador:=-1;
     reset(arejemplares);

     while (not eof(arejemplares)) and (not encontrado) do
        begin
          Inc(contador);
          read(arejemplares,ejemplartemp);
          encontrado:=(ejemplartemp.numero=numejemplar) and
                      (ejemplartemp.esta);

        end;

        if not encontrado then pos_fis_ejemplar:=-1 else
                pos_fis_ejemplar:=contador;
   end;

 {************************************************************************}

Function Ver_Genero_Estante (var argeneros:tar_generos;pasillo,
                             estante:integer):integer;

  {se le pasa una nß de pasillo y de estante y devuelve un integer
con el numero de genero de ese estante, devuelve 0 en caso de que no este
asignado}

   var
      genero:tr_genero;
      contgenero:byte;
      numhasta,numactual,numdesde:integer;
      encontrado:boolean;
   begin

    contgenero:=0;
    encontrado:=false;
    reset(argeneros);

    while (not eof(argeneros)) and (not encontrado) do
     begin
        inc(contgenero);
        read(argeneros,genero);
        numhasta:=
((genero.ubicacion_hasta.pasillo-1)*15)+genero.ubicacion_hasta.estante;
        numdesde:=
((genero.ubicacion_desde.pasillo-1)*15)+genero.ubicacion_desde.estante;

        numactual:=((pasillo-1)*15)+estante;
        encontrado:=(numactual<=numhasta) and (numactual>=numdesde);
     end;


    if not encontrado then Ver_Genero_Estante:=0
    else Ver_Genero_Estante:=contgenero;

   end;

         {********************************************************}

procedure menu_principal;


         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
         {}                                                      {}
         {}             {PROCEDIMIENTOS CON AUTORES}             {}
         {}                                                      {}
         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                         {ALTA DE UN AUTOR NUEVO}

        procedure alta_autor(var arAutores:tar_autores;var ind_autores:t_indice);

        var
             salir:char;
             autor:tr_autor;
             ingresado:boolean;

        begin
               repeat
                     clrscr;
                     write('Ingrese Autor: ');
                     readln(autor.nombre);
                     writeln;

                     ingresado:=insertar_autor(arAutores,autor,ind_autores);

                     if not ingresado then
                     begin
                        mensaje('   El autor ingresado ya se  ',' encuentra en la biblioteca  ');
                        readkey;
                        clrscr
                     end;

                     mensaje('  Desea ingresar otro autor? ','            (S/N)            ');
                     (salir):=readkey;
                     while (salir <> 's') and (salir <> 'n') do
                     begin
                        mensaje('      Opci¢n inv†lida!!      ','  presione cualquier tecla   ');
                        readkey;
                        clrscr;
                        mensaje('  Desea ingresar otro autor? ','            (S/N)            ');
                     	(salir):=readkey;
                     end;
               until (salir= 'n');
               textbackground(black);
               clrscr;
               menu_principal;
          end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
              {BAJA DE UN AUTOR EXISTENTE EN LA BIBLIOTECA}

procedure baja_autor(var archivoautor:tar_autores;
                     var archivotitulo:tar_titulos);
     var
        nomautor:string[40];
        encontrado,sacado:boolean;
        numautor:integer;
        salir:char;
     begin
     	repeat
          clrscr;
          write('Ingrese el nombre del autor que desea eliminar: ');
          readln(nomautor);
          numautor:=buscar_autor_nombre(archivoautor,nomautor);
          if numautor= 0 then
          begin
             mensaje('      No hay autores con     ',' ese nombre en la biblioteca ');
             readkey;
             clrscr
          end
          else
          begin
               encontrado:=buscar_numautor_titulos(archivotitulo,numautor);
               if encontrado then
               begin
                  mensaje('        Hay t°tulos de       ','  ese autor en la biblioteca ');
                  readkey;
                  clrscr;
                  mensaje('    Para eliminar un autor   ','  debe eliminar sus t°tulos  ');
                  readkey;
                  clrscr
               end
               else
               begin
                   sacado:=sacar_autor(archivoautor,nomautor);
                   if sacado then
                      mensaje('        El autor fue         ','   eliminado correctamente   ');
                      readkey;
                      clrscr;
               end;
          end;
           mensaje('  Desea eliminar otro autor? ','            (S/N)            ');
           (salir):=readkey;;
           while (salir <> 's') and (salir <> 'n') do
           	begin
                	mensaje('      Opci¢n inv†lida!!      ','  presione cualquier tecla   ');
                        readkey;
                        clrscr;
                        mensaje('  Desea eliminar otro autor? ','            (S/N)            ');
                        (salir):=readkey;
                end;
        until (salir= 'n');
        textbackground(black);
        clrscr;
        menu_principal;
     end;



        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
               {MODIFICA EL NOMBRE DE UN AUTOR PARTICULAR}

procedure modificar_autor (var ar_autor: tar_autores;var indice_autores:t_indice);
const esc= #27;
var  codigo: integer;
     nombre: t_nombre;
     autor:tr_autor;
begin
clrscr;
textbackground(red);
writeln ('MODIFICACI‡N DE AUTORES');
textbackground(black);
writeln;
write ('Ingrese el codigo de autor: ');
readln (codigo);
writeln;
reset (ar_autor);

 autor:=buscar_autor_numero(ar_autor,codigo,indice_autores);

 if autor.numero<>0 then
 begin
 writeln('Nombre de autor: ',autor.nombre);
 writeln;
 write ('Ingrese la modificacion del nombre: ');
 readln (nombre);
 writeln;
 Writeln ('El autor ',autor.nombre, ' ha sido modificado por ', nombre);
 autor.nombre:=nombre;
 seek (ar_autor,autor.numero-1);
 write (ar_autor,autor);
 readkey;

 end
 else
 begin
    mensaje ('      No hay autores con     ',' ese codigo en la biblioteca ');
    readkey;
 end;

mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;

        {********************************************************}
              {VISUALIZA TODOS LOS AUTORES DE LA BIBLIOTECA}

procedure visualizar_autores (var ar_autor: tar_autores);
var i, cont, aux: integer;
    autor: tr_autor;
begin
clrscr;
cont:= 0;
aux:= 2;
tabla_autores;
reset (ar_autor);
  for i:= 0 to (filesize (ar_autor)-1) do
    begin
    seek (ar_autor,i);
    read (ar_autor,autor);
      if ((aux>1) and (autor.esta=true)) then
      begin
      inc (cont);
      seek (ar_autor,i);
      gotoxy (1, cont+3);
      write (autor.numero);
      gotoxy (7, cont+3);
      write ('|', autor.nombre);
      gotoxy (29, cont+3);
      write ('|');

      if cont=18 then
        begin
           if quiere_continuar then
             begin
             clrscr;
             tabla_autores;
             cont:= 0;
             end
           else aux:= 0;
        end;
      end;
    end;
readkey;
mensaje('      Presione una tecla     ','para volver al menu principal');
readkey;
clrscr;
menu_principal;
end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
            {VISUALIZA UN AUTOR PARTICULAR DE LA BIBLIOTECA}

procedure vaut_ind (var ar_autor: tar_autores; var ar_titulo: tar_titulos;var ind_autores:t_indice);
var j, codigo, aux, cant: integer;
    autor: tr_autor;
    titulo: tr_titulos;
begin
clrscr;
cant:=0;
aux:= 2;
textbackground(red);
writeln ('VISUALIZACION INDIVIDUAL DE AUTORES');
textbackground(black);
writeln;
write ('Ingrese el codigo de autor: ');
readln (codigo);
writeln;
autor:=buscar_autor_numero(ar_autor,codigo,ind_autores);
if (autor.numero > 0) then
   begin
      writeln ('Nombre de autor : ', autor.nombre);
      writeln;
      reset (ar_titulo);
       for j:= 0 to (filesize (ar_titulo)-1) do
         begin
         seek (ar_titulo,j);
         read (ar_titulo,titulo);
          if (titulo.numero_autor = codigo) and (titulo.esta) then
           begin
            if aux>1 then
            begin
            seek (ar_titulo,j);
            inc (cant);
            escribir_dato_titulo (titulo);
                  if cant=4 then
                   begin
                      if quiere_continuar then
                         begin
                         clrscr;
                         cant:= 0;
                      end
                      else aux:= 0;
                   end;
            end;
           end;
         end;
   end
   else
   begin
    mensaje('      No hay autores con     ',' ese c¢digo en la biblioteca ');
   end;

readkey;
mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;

{//////////////////////////////////////////////////////////////////}
procedure pant_ini_imp_autor;

 begin

    textbackground(black);
    textcolor(white);
    clrscr;

    textbackground(red);
    gotoxy(16,2);
    write ('IMPORTACION DE AUTORES DESDE ARCHIVOS DE TEXTO');

    gotoxy(8,7);
    textbackground(black);
    cursoron;
    write('* -Dentro del archivo .txt cada renglon debe ser de la forma');
    gotoxy(8,8);
    write('   numero,nombredeautor ');

    gotoxy(8,10);
    write('* -si ya existe un autor con ese nombre no se modifica nada');
    gotoxy(8,12);
    write('* -Si ya existe un autor con ese numero se le cambia el nombre');
    gotoxy(8,14);
    write('* -Verifique que los datos sean correctos antes de la importacion');
    cursoroff;
    gotoxy(22,20);
    write('-------------------------------------');

 end;


procedure pant_fin_importacion(contimportacion,valimportacion,flagerror:boolean;direrror:string);
   begin

     if contimportacion then

          begin

           if (valimportacion)  then

               begin

                 if flagerror then
                    mensaje(' Resultado de la importacion ','       en '+direrror+'      ')
                 else
                    mensaje('        La importaci¢n       ',' fue realizada correctamente ');
               end

           else  mensaje('         El archivo          ','   especificado no existe    ');
           readkey;
         end;

         clrscr;
         mensaje('      Presione una tecla     ','para volver al menu principal');
         readkey;
     end;

function trans_cadena_autor(cadena:string):tr_autor;
   {se le pasa una cadena de texto y lo transforma
   en tr_autor solo si la cadena es del tipo num,nombre}
   var
     poscoma:byte;
     autor:tr_autor;

   begin
     poscoma:=pos(',',cadena);

     {lee hasta la primer coma de la cadena y carga eso en
     autortemp.numero en caso de que haya un dato erroneo carga cero}
     autor.numero:=strtointdef(copy(cadena,0,poscoma-1),0);
     delete(cadena,1,poscoma); {borra hasta la coma}

     {carga el nombre en autortemp.nombre}
     autor.nombre:=cadena;
     autor.esta:=true;
     trans_cadena_autor:=autor;
   end;

         {*********************************************************}
                      {IMPORTA AUTORES DESDE CSV}

procedure imp_autores_csv(var arautores:tar_autores;fecha:longint;var ind_autores:t_indice);
{carga un archivo csv en arautores, el texto debe ser
de la forma numero,autor}

var
    cadenatemp:string;
    archivotxt,archivoerror:text;

    autortemp:tr_autor;
    numautor:integer;
    ruta:string;
    valimportacion:boolean;

    errorimportacion,flagerror,contimportacion:boolean;
    cadenaerror:string;
    direrror:string[30];

begin
    flagerror:=false;
    valimportacion:=true;
    pant_ini_imp_autor;

    gotoxy(23,22);
    write('Continuar con importaci¢n (S/N)');

    contimportacion:=(readkey='s');

    cursoron;

    if contimportacion then
       begin
         clrscr;
         textbackground(red);
         gotoxy(23,5);
         write ('IMPORTACION DE AUTORES DESDE .TXT');

         gotoxy(10,10);
         textbackground(black);

         write('Ruta y nombre del archivo: ');
         readln(ruta);

         cursoroff;
         {asigna y abre el archivo en caso que exista}
         assign(archivotxt,RUTA);
         {$I-}
         reset(archivotxt);
         if ioresult<>0 then valimportacion:=false;
         {$I+}

         {recorre el archivo linea por linea cargando cada autor}
         {transforma cada linea en un tr_autor}

         while (valimportacion) and (not eof(archivotxt))  do

            begin

              errorimportacion:=true;
              cadenaerror:='';

              {lee un renglon y lo transforma en un tr_autor}
              readln(archivotxt,cadenatemp);
              autortemp:=trans_cadena_autor(cadenatemp);

              {se fija si hay un autor con ese nombre}
              numautor:=buscar_autor_nombre(arautores,autortemp.nombre);

              {si no hay un autor con ese nombre ni con ese numero
              lo carga al final.si ya hay un autor con ese numero
              le cambia el nombre}
              {en caso de que ocurra un cambio el programa guarda en una cadena
              el tipo de cambio que se hizo para crear un archivo de error}

              readkey;
              if (numautor=0) then
                  if (autortemp.numero<>0) then
                      begin
                        if (autortemp.numero<=(filesize(arautores)+1))  then
                           begin
                             errorimportacion:=false;
                             seek(arautores,autortemp.numero-1);
                             write(arautores,autortemp);
                             inc(ind_autores.cantidad);
                             ind_autores.v_indice[ind_autores.cantidad].clave:=autortemp.numero;
                             ind_autores.v_indice[ind_autores.cantidad].pos:=autortemp.numero-1;
                             ordenar_indice(ind_autores);
                           end

                        else
                            begin
                              insertar_autor(arautores,autortemp,ind_autores);
                              numautor:=buscar_autor_nombre(arautores,autortemp.nombre);
                              if numautor<>autortemp.numero then
                              cadenaerror:='  "..al autor se le ha asignado el numero '+inttostr(numautor)+' automaticamente.."';
                            end;
                      end
                  else cadenaerror:='  "..el numero de autor no es un codigo valido.."'
               else cadenaerror:='  "..ya existe un autor con ese nombre.."';

               {si ha ocurrido un error lo guarda en el archivo de texto}
               if errorimportacion then
                  begin

                      if not flagerror then

                         begin
                           direrror:='Res_imp_A.txt';
                           assign(archivoerror,direrror);
                           rewrite(archivoerror);
                         end;
                      writeln(archivoerror,cadenatemp,' ',cadenaerror);
                      flagerror:=true;
                  end;

            end;
        end;

        if flagerror then close(archivoerror);
        close(archivotxt);
        {mensages para el usuario}
        pant_fin_importacion(contimportacion,valimportacion,flagerror,direrror);

        clrscr;
        menu_principal;
end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
        {}                                                    {}
        {}            {PROCEDIMIENTOS CON T÷TULOS}            {}
        {}                                                    {}
        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                       {ALTA DE UN T÷TULO NUEVO}


          procedure alta_titulo(var arTitulos:tar_titulos; var arAutores:tar_autores);

          var
             salir,opcion:char;
             nombreTitulo,nombreAutor:t_nombre;
             numtitulo,numAutor,numGenero:integer;
             titulo:tr_titulos;
             ingresado:boolean;

          begin
               repeat
               	     clrscr;
                     write('Ingrese nombre del libro: ');
                     readln(nombreTitulo);
                     writeln;

                     numtitulo:=buscar_titulo_nombre(arTitulos,nombreTitulo);

                     if numtitulo>0 then
                     begin
                         mensaje('  El t°tulo ingresado ya se  ',' encuentra en la biblioteca  ');
                         readkey;
                         clrscr;
                     end
                     else
                     begin
                         titulo.nombre:=nombreTitulo;
                         write('Ingrese nombre del autor: ');
                         readln(nombreAutor);
                         writeln;

                         numAutor:=buscar_autor_nombre(arAutores,nombreAutor);

                         if numAutor>0 then
                         begin
                            repeat

                            titulo.numero_autor:=numAutor;

                            writeln('Elija genero: ');
                            writeln(' 1-Novela');
                            writeln(' 2-Ensayo');
                            writeln(' 3-Ciencia');
                            writeln(' 4-Humanidades');
                            writeln(' 5-Infantil');
                            writeln(' 6-Diccionario');
                            write(' 7-Otros:  ');
                            readln(numGenero);
                            if numGenero<=7 then
                                titulo.numero_genero:=numGenero
                            else
                                mensaje('     Opci¢n no valida!!      ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;

                            until (numGenero<=7);

                            ingresado:=insertar_titulo(arTitulos,titulo);

                            if ingresado then
                            begin
                               mensaje('          El titulo          ','   fue ingresado con Çxito   ');
                               readkey;
                               clrscr;
                            end;
                         end
                         else
                         begin
                             mensaje('  El autor ingresado no se   ',' encuentra en la biblioteca  ');
                             readkey;
                             clrscr;
                             mensaje('   Para ingresar un titulo   ','debe primero existir su autor');
                             readkey;
                             clrscr;
                         end;

                     mensaje(' Desea ingresar otro titulo? ','            (S/N)            ');
                     salir:=readkey;
                     clrscr;

                     case (salir) of
                        's': begin alta_titulo(arTitulos,arAutores); end;
                        'n': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                           mensaje('     Opci¢n no valida!!      ','   Presione cualquier tecla  ');
                           readkey;
                           clrscr;
                           mensaje(' Desea ingresar otro titulo? ','            (S/N)            ');
                     	   salir:=readkey;
                           clrscr;
                        end;
                     end;

               until (salir='n');
               textbackground(black);
               clrscr;
               menu_principal;
          end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

procedure baja_titulo(var archtitulo:tar_titulos; var archejemplar:
                      tar_ejemplares);
     var
     	nomtit:string[40];
     	numtit:integer;
     	existe,borrado:boolean;
     	salir:char;
     begin
     	repeat
     		clrscr;
     	        write('Ingrese titulo que desea borrar: ');
     		readln(nomtit);
     		numtit:=buscar_titulo_nombre(archtitulo,nomtit);

     		if numtit=0 then
                begin
                  mensaje('      No hay titulos con     ',' ese nombre en la biblioteca ');
                  readkey;
                  clrscr
                end
     		else
     		begin
     			existe:=buscar_numtitulo_ejemplares(archejemplar,numtit);
     			if existe then
                        begin
                           mensaje('      Hay ejemplares de      ',' ese t°tulo en la biblioteca ');
                           readkey;
                           clrscr;
                           mensaje('   Para eliminar un titulo   ',' debe eliminar sus ejemplares');
                           readkey;
                           clrscr
                        end
     			else
     			begin

     			borrado:=sacar_titulo(archtitulo,nomtit);

     			if borrado then
                        begin
                           mensaje('        El t°tulo fue        ','   eliminado correctamente   ');
                           readkey;
                           clrscr
     			end;
                        end;
     		end;

         mensaje(' Desea eliminar otro titulo? ','            (S/N)            ');
         (salir):=readkey;
         while (salir <> 's') and (salir <> 'n') do
         	begin
                	mensaje('      Opci¢n inv†lida!!      ','  presione cualquier tecla   ');
                        readkey;
                        clrscr;
                        mensaje(' Desea eliminar otro titulo? ','            (S/N)            ');
                        (salir):=readkey;
                end;

        until (salir= 'n');

        textbackground(black);
        clrscr;
        menu_principal;
     end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
               {MODIFICA EL NOMBRE DE UN T÷TULO PARTICULAR}

procedure modificar_titulos (var ar_titulo: tar_titulos);
var  codigo: integer;
     nombre: t_nombre;
     titulo:tr_titulos;
begin
clrscr;
textbackground(red);
writeln ('MODIFICACION DE TITULOS');
textbackground(black);
writeln;
write ('Ingrese el codigo de titulos: ');
readln (codigo);
writeln;
reset (ar_titulo);

titulo:=buscar_titulo_numero(ar_titulo,codigo);

 if titulo.numero<>0 then
 begin
 writeln('El nombre del t°tulo es: ',titulo.nombre);
 writeln;
 write ('Ingrese la modificacion del nombre: ');
 readln (nombre);
 writeln;
 seek (ar_titulo,titulo.numero-1);
 Writeln ('El titulo ',titulo.nombre, ' ha sido modificado por ', nombre);
 titulo.nombre:=nombre;
 write (ar_titulo,titulo);
 readkey;
 end
 else
 begin
    mensaje ('      No hay titulos con     ',' ese codigo en la biblioteca ');
    readkey;
 end;

mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;

         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
              {VISUALIZA TODOS LOS T÷TULOS DE LA BIBLIOTECA}

procedure visualizar_titulos (var ar_titulo: tar_titulos);
var i, cont, aux: integer;
    titulo: tr_titulos;
begin
clrscr;
cont:= 0;
aux:= 2;
tabla_titulos;
reset (ar_titulo);
for i:= 0 to (filesize (ar_titulo)-1) do
 begin
 seek (ar_titulo,i);
 read (ar_titulo,titulo);
   if (aux>1) and (titulo.esta=true) then
    begin
    inc (cont);
    seek (ar_titulo,i);
    gotoxy  (1, cont+3);
    write (titulo.numero);
    gotoxy  (17, cont+3);
    write ('|',titulo.nombre);
    gotoxy  (38, cont+3);
    write ('|',titulo.numero_autor);
    gotoxy  (54, cont+3);
    write ('|',titulo.numero_genero);
    gotoxy  (72, cont+3);
    write ('|');
      if cont=18 then
        begin
           if quiere_continuar then
            begin
              clrscr;
              tabla_titulos;
              cont:= 0;
            end
            else aux:= 0;
        end;
    end;
 end;
readkey;
mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
            {VISUALIZA UN T÷TULO PARTICULAR DE LA BIBLIOTECA}

procedure vtit_ind (var ar_titulo: tar_titulos);

var codigo: integer;
    titulo: tr_titulos;

begin

clrscr;
textbackground(red);
writeln ('VISUALIZACI‡N INDIVIDUAL DE TITULOS');
textbackground(black);
writeln;
write ('Ingrese el codigo de titulo: ');
readln (codigo);
writeln;
reset (ar_titulo);
titulo:=buscar_titulo_numero(ar_titulo,codigo);

if titulo.numero>0  then
begin
   escribir_dato_titulo (titulo);
end
else
begin
   mensaje('      No hay titulos con     ',' ese codigo en la biblioteca ');
   readkey;
end;
readkey;
mensaje('      Presione una tecla     ','para volver al menu principal');
readkey;
clrscr;
menu_principal;
end;
{//////////////////////////////////////////////////////////////////////}
procedure pant_ini_imp_tit;

  begin
    textbackground(black);
    textcolor(white);
    clrscr;

    textbackground(red);
    gotoxy(16,2);
    write ('IMPORTACION DE TITULOS DESDE ARCHIVOS DE TEXTO');

    gotoxy(8,7);
    textbackground(black);
    cursoron;
    write('* -Dentro del archivo .txt cada renglon debe ser de la forma');
    gotoxy(8,8);
    write('   numero,nombredetitulo,numeroautor,numerogenero ');
    gotoxy(8,10);
    write('* -si ya existe un titulo con ese nombre no se modifica nada');
    gotoxy(8,12);
    write('* -Si el numero de titulo excede el total de titulos');
    gotoxy(8,13);
    write ('   el sistema le asigna un numero automaticamente  ');
    gotoxy(8,15);
    write('* -Verifique que los datos sean correctos antes de la importacion');
    cursoroff;
    gotoxy(20,20);
    write('-------------------------------------');
  end;


function trans_cadena_titulo(cadena:string):tr_titulos;
{transforma una cadena del tipo numtit,nombre,numaut,numgen
 a un tr_titulo}
 var
  titulo:tr_titulos;
  campos:array[1..4] of string;
  contador:1..4;
  poscoma:byte;

 begin
      {carga los campos en un vector}
      for contador:=1 to 4 do
         begin
           poscoma:=pos(',',cadena);
           if poscoma=0 then poscoma:=length(cadena)+1;
           campos[contador]:=copy(cadena,1,poscoma-1);
           delete(cadena,1,poscoma);
         end;

      {carga los datos del vector en un tr_titulo}
      titulo.numero:=strtointdef(campos[1],0);
      titulo.nombre:=campos[2];
      titulo.numero_autor:=strtointdef(campos[3],0);
      titulo.numero_genero:=strtointdef(campos[4],0);
      titulo.esta:=true;
      trans_cadena_titulo:=titulo;
 end;
         {**********************************************************}
                       {CARGA TITULOS DESDE CSV}

procedure imp_titulos_csv(var artitulos:tar_titulos;var
                          arautores:tar_autores;
                          var ind_autores:t_indice);

var
    cadenatemp:string;


    titulotemp:tr_titulos;
    archivotxt:text;


    ruta:string;

    numtitulo:integer;


    titulo:tr_titulos;
    autor:tr_autor;

    valido:boolean;
    valimportacion,contimportacion:boolean;
begin

    pant_ini_imp_tit;

    gotoxy(23,22);
    write('Continuar con importaci¢n (S/N)');

    contimportacion:=readkey='s';

   if contimportacion then
      begin

        clrscr;
        textbackground(red);
        gotoxy(23,5);
        write ('IMPORTACION DE TITULOS DESDE .TXT');

        gotoxy(10,10);
        textbackground(black);

        write('Ruta y nombre del archivo: ');
        readln(ruta);


        {asigna y abre el archivo en caso que exista}
        assign(archivotxt,RUTA);
        {$I-}
        reset(archivotxt);
        if ioresult<>0 then valimportacion:=false;
        {$I+}

        {recorre el archivo linea por linea cargando cada autor}
        {transforma cada linea en un tr_titulo}
        while (valimportacion) and (not eof(archivotxt)) do
             begin

                readln(archivotxt,cadenatemp);
                titulotemp:=trans_cadena_titulo(cadenatemp);


                {carga el titulo}
                titulo:=buscar_titulo_numero(artitulos,titulotemp.numero);
                {carga el autor}

                autor:=buscar_autor_numero(arautores,titulotemp.numero_autor,ind_autores);

                {valida para hacer la alta que...los nß sean validos,
                o sea<>0 que exista los autores y generos y que no exista
                otro titulo con ese nombre}

                valido:=(titulo.numero=0) and (titulotemp.numero>0) and
                (titulotemp.numero_genero<=MAX_GENERO) and
                (titulotemp.numero_genero>0) and (autor.numero<>0);

                {si se cuplen todas las condiciones hace el alta de titulo}
                {si el numero de titulo es mayor al total de titulos lo
                inserta en el primer lugar libre y le cambia el numero}



                if valido then
                  if titulotemp.numero>filesize(artitulos) then
                   insertar_titulo(artitulos,titulotemp)
                  else
                        begin
                          seek(artitulos,
                          titulotemp.numero-1);
                          write(artitulos,titulotemp);
                        end;

             end;

         cursoroff;

         if valimportacion then
         begin
            clrscr;
            mensaje('        La importaci¢n       ',' fue realizada correctamente ');
            readkey;
            mensaje('      Presione una tecla     ','para volver al menu principal');
            readkey
         end
         else
         begin
            clrscr;
            mensaje('         El archivo          ','   especificado no existe    ');
            readkey;
            mensaje('      Presione una tecla     ','para volver al menu principal');
            readkey;
         end;
        end;
        close(archivotxt);
        clrscr;
        menu_principal;

     end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
        {}                                                     {}
        {}             {PROCEDIMIENTOS CON GêNEROS}            {}
        {}                                                     {}
        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
              {VISUALIZA TODOS LOS GêNEROS DE LA BIBLIOTECA}

procedure visualizar_generos (var ar_genero: tar_generos);
var i: integer;
    gen: tr_genero;
begin
clrscr;
writeln ('--------------------------GENEROS--------------------------------');
writeln ('Numero |      Nombre         |Ubicacion desde | Ubicacion hasta |');
writeln ('       |                     |Pasillo |Estante|Pasillo |Estante |');
writeln ('----------------------------------------------------------------|');
reset (ar_genero);
for i:= 0 to (filesize (ar_genero)-1) do
  begin
     seek (ar_genero,i);
     read (ar_genero, gen);
     gotoxy  (1, i+5);
     write (gen.numero);
     gotoxy  (8, i+5);
     write ('|', gen.nombre);
     gotoxy  (30, i+5);
     write ('|', gen.ubicacion_desde.pasillo);
     gotoxy  (39, i+5);
     write ('|', gen.ubicacion_desde.estante);
     gotoxy  (47, i+5);
     write ('|', gen.ubicacion_hasta.pasillo);
     gotoxy  (56, i+5);
     write ('|', gen.ubicacion_hasta.estante);
     gotoxy  (65, i+5);
     write ('|');
  end;
writeln;
writeln ('-----------------------------------------------------------------');

readkey;
mensaje('      Presione una tecla     ','para volver al menu principal');
readkey;
clrscr;
menu_principal;
end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                   {VISUALIZA UN GêNERO EN PARTICULAR}

procedure vgen_ind (var ar_titulo: tar_titulos; var ar_genero: tar_generos);

var  codigo,cant: integer;
     titulo: tr_titulos;
     genero: tr_genero;

begin
cant:=3;
clrscr;
textbackground(red);
writeln ('VISUALIZACI¢N INDIVIDUAL DE GENEROS');
textbackground(black);
writeln;
write ('Ingrese el codigo de genero: ');
readln (codigo);
writeln;

genero:=buscar_genero_numero(ar_genero,codigo);

if genero.numero<>0 then
begin
   writeln ('Nombre del gÇnero:        ',genero.nombre);
   writeln ('N£mero del gÇnero:        ',genero.numero);
   writeln ('Ubicacion desde: pasillo: ',genero.ubicacion_desde.pasillo);
   writeln ('                 estante: ',genero.ubicacion_desde.estante);
   writeln ('Ubicacion hasta: pasillo: ',genero.ubicacion_hasta.pasillo);
   writeln ('                 estante: ',genero.ubicacion_hasta.estante);
   writeln;

   reset(ar_titulo);
   while not eof(ar_titulo) do
   begin
      read(ar_titulo,titulo);
      if (titulo.numero_genero=codigo) and (titulo.esta) then
      begin
         inc(cant);
         escribir_dato_titulo (titulo);
         if cant=5 then
         begin
            if quiere_continuar then
            begin
               clrscr;
               cant:= 0;
            end;
         end;
      end;
   end;
end

else
begin
   mensaje('     No hay generos con      ',' ese codigo en la biblioteca ');
end;

readkey;
mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
             {MODIFICACION EN LA UBICACION DE LOS GENEROS}

procedure Modificar_Genero(var arejemplares:tar_ejemplares;var
                           argeneros:tar_generos);

   var

    numopc:0..25;
    opcelegida:char;
    sectorelegido:0..25;
    numgenero:integer;

    opcval:array[0..25]of byte;
    cantopc:0..25;

    hastanumestante,desdenumestante:integer;
    contador:integer;
    numestantedest,numestanteor:integer;{}
    nuevaubidesde,nuevaubihasta:tr_ubicacion;

    viejaubidesde:tr_ubicacion;
    desdepasillo,desdeestante,hastapasillo,hastaestante:integer;
    generotemp:tr_genero;


    n:integer;
   begin
    {leo el genero a modificar}

    numestantedest:=0;
    numestanteor:=0;
    contador:=0;


    repeat
      repeat
       textbackground(black);
       clrscr;

       gotoxy(17,26);
       write('Atenci¢n! Los ejemplares que se encuentren en ');
       gotoxy(17,27);
       write('el genero seran trasladados a los nuevos estantes');

       gotoxy(20,5);
       textbackground(red);
       write('MODIFICACION DE GENEROS (Ubicaci¢n)');
       textbackground(black);

       gotoxy(25,8);
       cursoron;
       Write('Modificar genero nß: ');
       read(numgenero);
      until (numgenero>0) and (numgenero<8);

      seek(argeneros,numgenero-1);
      read(argeneros,generotemp);

      {carga la pos del sector viejo}
      viejaubidesde:=generotemp.ubicacion_desde;


      gotoxy(25,10);
      write('--------------------------');
      gotoxy(25,12);
      write ('Nombre: ',generotemp.nombre);
      gotoxy(25,13);
      write('N£mero: ',generotemp.numero);
      gotoxy(25,14);
      write ('Desde pasillo ',viejaubidesde.pasillo,'  Desde estante ',viejaubidesde.estante);
      gotoxy(25,15);
      write('Hasta pasillo ',generotemp.ubicacion_hasta.pasillo,'  Hasta estante ',generotemp.ubicacion_hasta.estante);
      gotoxy(25,17);
      write('--------------------------');
      gotoxy(26,18);
      write('S:CONTINUAR MODIFICACI‡N');
      gotoxy(30,19);
      write('X:CAMBIAR GENERO');

      until 's'=readkey;



    clrscr;
    gotoxy(7,3);
    writeln('NUEVAS UBICACIONES POSIBLES DEL GENERO ',generotemp.nombre);
    writeln;

       {carga el encabezado de la tabla}
       writeln('                   desde                hasta');
       writeln  ('    opcion','| pasillo    estante |  pasillo   estante |');
       writeln;


       {***********************************************************}
       {recorre los intervalos y valida los sectores que se pueden elegir}
       {y los pone en el vector opcval}
       {para que se puedan elegir deben estar vacios}

       hastapasillo:=1;
       cantopc:=0;
       numopc:=0;

       for contador:=1 to 21 do
         begin

            hastanumestante:=contador*7;
            nuevaubihasta:=Ver_Ubicacion(hastanumestante);
            desdenumestante:=hastanumestante-6;
            nuevaubidesde:=Ver_Ubicacion(desdenumestante);

              desdepasillo:=nuevaubidesde.pasillo;
              desdeestante:=nuevaubidesde.estante;
              hastapasillo:= nuevaubihasta.pasillo;
              hastaestante:=nuevaubihasta.estante;

              {verifica que los estantes esten vacios}
              if
Ver_Genero_Estante(argeneros,nuevaubidesde.pasillo,nuevaubidesde.estante)=0
then
                begin
                 numopc:=numopc+1;
                 writeln (numopc:9,' | ',desdepasillo:7,' | ',desdeestante:7,'  |  ',hastapasillo:7,' | ',hastaestante:7 ,' |');

                 {carga las opciones posibles en un contador}
                 Inc(cantopc);
                 opcval[cantopc]:=contador;

                end;
       end;

        textbackground(red);
        gotoxy(25,25);
        write('Opci¢n elegida: ');
        textbackground(black);
        cursoroff;
        readln(numopc);

        numestanteor:=((viejaubidesde.pasillo-1)*15)+viejaubidesde.estante;
        sectorelegido:=opcval[numopc];
        numestantedest:=(sectorelegido*7)-6;
          {busca la pocision del sector elegido}



        generotemp.ubicacion_desde:=Ver_Ubicacion(numestantedest);
        generotemp.ubicacion_hasta:=Ver_Ubicacion(numestantedest+6);

        {cambia la posicion sobre el registro generos}
        seek(argeneros,numgenero-1);
        write(argeneros,generotemp);

        {mueve los ejemplares a su nueva ubicacion(desde numestantedest
        a numestanteor}
        nuevaubidesde:=Ver_Ubicacion(numestantedest);
        viejaubidesde:=Ver_Ubicacion(numestanteor);

        for contador:=1 to 7 do
          begin

Mover_Estante(arejemplares,viejaubidesde.pasillo,viejaubidesde.estante
                        ,nuevaubidesde.pasillo,nuevaubidesde.estante);

            Inc(numestantedest);
            Inc(numestanteor);


            nuevaubidesde:=Ver_Ubicacion(numestantedest);
            viejaubidesde:=Ver_Ubicacion(numestanteor);
          end;

        mensaje('       La modificaci¢n       ','   fue realizada con Çxito   ');
        readkey;
        clrscr;
        menu_principal;
end;

        {********************************************************}

     {MUESTRA UN MAPA DE LA BIBLIOTECA CON LA DISTRIBUCI‡N DE LOS GENEROS}


        procedure mapa_general(var arGeneros:tar_generos);

        type    tvector=array [1..MAX_GENERO] of tr_genero;

        var     i,j,k,m,q,estante,pasillo:integer;

                pi:^tvector;

        begin
                dibujar_mapa;

                pi:=nil;

                new(pi);

                reset(arGeneros);

                q:=1;

                while not eof(arGeneros) do
                begin
                   read(arGeneros,pi^[q]);
                   inc(q);
                end;

                for i:=1 to MAX_GENERO do
                begin
                   if (pi^[i].ubicacion_desde.pasillo=pi^[i].ubicacion_hasta.pasillo) then
                   begin
                      for j:=1 to 7 do
                      begin
                         pasillo:=2;
                         k:=1;
                         while (k<=10) and (k<=pi^[i].ubicacion_desde.pasillo) do
                         begin
                            if k=pi^[i].ubicacion_desde.pasillo then
                            begin
                               estante:=pi^[i].ubicacion_desde.estante;
                               gotoxy(pasillo,estante+j);
                               textbackground(i);
                               write('_____');
                            end;
                            pasillo:=pasillo+8;
                            inc(k);
                         end;
                      end;
                   end

                   else
                   begin
                      k:=1;

                      pasillo:=2;

                      while (k<=10) and (k<=pi^[i].ubicacion_hasta.pasillo) do
                      begin

                         if k=pi^[i].ubicacion_desde.pasillo then
                         begin
                            j:=pi^[i].ubicacion_desde.estante;
                            while j<=15 do
                            begin
                               m:=1;
                               estante:=j;
                               gotoxy(pasillo,estante+m);
                               textbackground(i);
                               write('_____');
                               inc(m);
                               inc(j);
                            end;
                         end

                         else
                         begin
                            if k=pi^[i].ubicacion_hasta.pasillo then
                            begin
                               j:=1;
                               while j<=pi^[i].ubicacion_hasta.estante do
                               begin
                                  m:=1;
                                  estante:=j;
                                  gotoxy(pasillo,estante+m);
                                  textbackground(i);
                                  write('_____');
                                  inc(m);
                                  inc(j);
                               end;
                            end;
                         end;

                         inc(k);
                         pasillo:=pasillo+8;
                      end;
                   end;

                end;

                        gotoxy(1,20);
                        textbackground(1);
                        write('   ');
                        textbackground(black);
                        write('  Novela');
                        gotoxy(21,20);
                        textbackground(2);
                        write('   ');
                        textbackground(black);
                        write('  Ensayo');
                        gotoxy(41,20);
                        textbackground(3);
                        write('   ');
                        textbackground(black);
                        write('  Ciencia');
                        gotoxy(1,22);
                        textbackground(4);
                        write('   ');
                        textbackground(black);
                        write('  Humanidades');
                        gotoxy(21,22);
                        textbackground(5);
                        write('   ');
                        textbackground(black);
                        write('  Infantil');
                        gotoxy(41,22);
                        textbackground(6);
                        write('   ');
                        textbackground(black);
                        write('  Diccionario');
                        gotoxy(1,24);
                        textbackground(7);
                        write('   ');
                        textbackground(black);
                        write('  Otros');
                        gotoxy(21,24);
                        write('[ ]') ;
                        write('  Vacio');
                readkey;
                dispose(pi);
                mensaje('      Presione una tecla     ','para volver al men£ principal');
                readkey;
                clrscr;
                menu_principal;
        end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
        {}                                                    {}
        {}            {PROCEDIMIENTOS CON SOCIOS}             {}
        {}                                                    {}
        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                       {ALTA DE UN NUEVO SOCIO}

procedure alta_socio(var arch:tar_socios);

var   numero,ubicacion:integer;
      socio:tr_socio;
      ingresado:boolean;
      salir:char;

begin
repeat
   clrscr;
   ingresado:=false;
   write('Ingrese nombre del socio: ');
   readln(socio.nombre);
   writeln;
   numero:=buscar_socio_nombre(arch,socio.nombre);

   if numero=0 then
   begin
      write('Ingrese n£mero de DNI: ');
      readln(socio.dni);
      writeln;
      write('Ingrese su direcci¢n: ');
      readln(socio.direccion);
      writeln;
      ubicacion:=buscar_lugar_socio(arch);
      ingresado:=insertar_socio(arch,socio);

   end
   else
   begin
      mensaje('  El socio ingresado ya se   ',' encuentra en la biblioteca  ');
      readkey;
      clrscr
   end;

   if ingresado then
   begin
      mensaje('          El socio           ','   fue ingresado con Çxito   ');
      readkey;
      clrscr;
   end;

   mensaje('  Desea ingresar otro socio? ','            (S/N)            ');
   (salir):=readkey;
   while (salir <> 's') and (salir <> 'n') do
   begin
      mensaje('      Opci¢n inv†lida!!      ','  presione cualquier tecla   ');
      readkey;
      clrscr;
      mensaje('  Desea ingresar otro socio? ','            (S/N)            ');
      (salir):=readkey;
   end;

until (salir='n');

clrscr;
menu_principal;

end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

procedure baja_socio(var archivosocio:tar_socios; var
archivoprestamo:tar_prestamos);
     var
        nomsocio:string[40];
        encontrado,sacado:boolean;
        numsocio:integer;
        salir:char;
     begin
     	repeat
          clrscr;
          write('Ingrese el nombre del socio que desea borrar: ');
          readln(nomsocio);
          numsocio:=buscar_socio_nombre(archivosocio,nomsocio);
          if numsocio= 0 then
          begin
             mensaje('      No hay socios con      ',' ese nombre en la biblioteca ');
             readkey;
             clrscr
          end
          else
          begin

encontrado:=buscar_numsocio_prestamos(archivoprestamo,numsocio);
               if encontrado then
               begin
                  mensaje('        El socio tiene       ',' ejemplares de la biblioteca ');
                  readkey;
                  clrscr;
               end
               else
               begin
                   sacado:=sacar_socio(archivosocio,nomsocio);
                   if sacado then
                   begin
                      mensaje('        El socio fue         ','   eliminado correctamente   ');
                      readkey;
                      clrscr;
                   end;
               end;
          end;
           mensaje('  Desea eliminar otro socio? ','            (S/N)            ');
           (salir):=readkey;
           while (salir <> 's') and (salir <> 'n') do
           	begin
                	mensaje('      Opci¢n inv†lida!!      ','  presione cualquier tecla   ');
                        readkey;
                        clrscr;
                        mensaje('  Desea eliminar otro socio? ','            (S/N)            ');
                        (salir):=readkey
                end;
        until (salir= 'n');
        textbackground(black);
        clrscr;
        menu_principal;
     end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
            {MODIFICA LOS DATOS DE UN SOCIO EN PARTICULAR}

procedure modificar_socios (var ar_socio: tar_socios);
var  codigo: integer;
     nombre: t_nombre;
     socio:tr_socio;
     car: char;
     dni: string [15];
     direccion: string [30];
begin
clrscr;
textbackground(red);
writeln ('MODIFICACION DE SOCIOS');
textbackground(black);
writeln;
write ('Ingrese el numero de codigo: ');
readln (codigo);
writeln;
reset (ar_socio);

socio:=buscar_socio_numero(ar_socio,codigo);

 if socio.numero>0 then
 begin
 writeln('El nombre del socio es   : ',socio.nombre);
 writeln('El DNI del socio es      : ',socio.dni);
 writeln('La direccion del socio es: ',socio.direccion);
 writeln;
  repeat
  writeln ('Desea modificar el nombre? (S/N)');
  writeln;
  (car):=readkey;;
  until ((car='s') or (car='n'));
   if car='s' then
   begin
   write ('Ingrese la modificacion del nombre: ');
   writeln;
   readln (nombre);
   seek (ar_socio,socio.numero-1);
   writeln ('El socio ',socio.nombre, ' ha sido modificado por ', nombre);
   writeln;
   socio.nombre:=nombre;
   write (ar_socio,socio);
   readkey;
   end;
  repeat
  writeln ('Desea modificar el DNI? (S/N)');
  writeln;
  (car):=readkey;
  until ((car='s') or (car='n'));
   if car='s' then
   begin
   write ('Ingrese la modificacion del DNI:');
   writeln;
   readln (dni);
   seek (ar_socio,socio.numero-1);
   writeln ('El DNI ',socio.dni, ' ha sido modificado por ', dni);
   writeln;
   socio.dni:=dni;
   write (ar_socio,socio);
   readkey;
   end;
  repeat
  writeln ('Desea modificar la direccion? (S/N)');
  writeln;
  (car):=readkey;
  until ((car='s') or (car='n'));
   if car='s' then
   begin
   write ('Ingrese la nueva direcci¢n:');
   writeln;
   readln (direccion);
   seek (ar_socio,socio.numero-1);
   Writeln ('La direcci¢n ',socio.direccion, ' ha sido modificada por ', direccion);
   socio.direccion:=direccion;
   write (ar_socio,socio);
   readkey;
   end;
  end
  else
  begin
    mensaje ('      No hay socios con      ',' ese codigo en la biblioteca ');
    readkey;
  end;
mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                    {VISUALIZA UN SOCIO EN PARTICULAR}

procedure ver_socios (var ar_socios: tar_socios; var ar_prestamos: tar_prestamos);

var socios: tr_socio;
    prestamo: tr_prestamo;
    codigo,cant: integer;
    hay:boolean;

begin
clrscr;
hay:=false;
textbackground(red);
writeln ('VISUALIZACI‡N INDIVIDUAL DE SOCIOS');
textbackground(black);
writeln;
write ('Ingrese el codigo de socio: ');
readln (codigo);
clrscr;
cant:=0;
reset (ar_socios);

writeln ('----------------------------------SOCIOS---------------------------------------');
writeln ('     Numero     |       Nombre       |      DNI      |         Direccion       |');
writeln ('----------------|--------------------|---------------|-------------------------|');

socios:=buscar_socio_numero(ar_socios,codigo);
writeln;
writeln ('-------------------------------------------------------------------------------');


 if socios.numero>0 then
 begin
   gotoxy  (1, 4);
   write (socios.numero);
   gotoxy  (17,4);
   write ('|',socios.nombre);
   gotoxy  (38,4);
   write ('|',socios.dni);
   gotoxy  (54,4);
   write ('|',socios.direccion);
   gotoxy  (80,4);
   writeln('|');

   gotoxy(1,7);
   textbackground(red);
   writeln('LIBROS ADEUDADOS POR ESTE SOCIO: ');
   textbackground(black);

   reset(ar_prestamos);
   while not eof(ar_prestamos) do
   begin
      inc(cant);
      read (ar_prestamos,prestamo);
      if (prestamo.num_socio = codigo) and (prestamo.esta) then
      begin

            writeln;
            writeln ('Numero de ejemplar: ', prestamo.num_ejemplar);
            writeln ('Fecha  : ', prestamo.fecha);
            hay:=true;

            if cant=4 then
            begin
               if quiere_continuar then
               begin
                  clrscr;
                  cant:= 0;
               end;
            end;
      end;
    end;

    if not hay then
    begin
       writeln;
       writeln('   Ninguno');
    end;
  end
  else
  begin
  mensaje('     No hay socios con       ',' ese codigo en la biblioteca ');
  end;
readkey;
mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
        {}                                                    {}
        {}           {PROCEDIMIENTOS CON EJEMPLARES}          {}
        {}                                                    {}
        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
          {REALIZA EL INGRSO DE UN EJEMPLAR EN LA BIBLIOTECA}

procedure estante_no_valido (var num_estante: byte);
begin
mensaje('     Estante no valido!!     ','   Presione cualquier tecla  ');
readkey;
clrscr;
write('Ingrese el numero de estante(1-15): ');
readln(num_estante);
writeln;
end;

procedure pasillo_no_valido (var num_pasillo: byte);
begin
mensaje('     Pasillo no valido!!     ','   Presione cualquier tecla  ');
readkey;
clrscr;
write('Ingrese el nÈmero de pasillo(1-10): ');
readln(num_pasillo);
writeln;
end;

procedure ingreso_ejemplar(var arch_ejem: tar_ejemplares; var arch_tit: tar_titulos; var arch_gen: tar_generos);
var num_pasillo:byte;
    num_estante:byte;
    ejemplar,ejemplartemp:tr_ejemplar; {}
    num_titulo:integer;
    nombre:t_nombre;
    titulo:tr_titulos;
    genero:tr_genero;
    resp: char;
    insertado,estante_valido: boolean;

begin
   {ingreso numero de ejemplar}
 repeat
  clrscr;
  write('Ingrese numero de ejemplar: ');
  readln(ejemplar.numero);
  writeln;
  ejemplartemp:= buscar_ejemplar_numero(arch_ejem,ejemplar.numero);
    if ejemplartemp.numero > 0 then
     begin
      mensaje('    Ya hay un ejemplar con   ',' ese codigo en la biblioteca ');
      readkey;
      clrscr;
     end
     else
      begin
      write('Ingrese nombre del titulo: ');
      readln(nombre);
      writeln;
      {valido el codigo del titulo ingresado}
      num_titulo:=buscar_titulo_nombre(arch_tit,nombre);
       if (num_titulo = 0) then
        begin
          mensaje('  El titulo ingresado no se  ',' encuentra en la biblioteca  ');
          readkey;
          mensaje('  Para ingresar un ejemplar  ','   debe existir su titulo    ');
          readkey;
        end
       else
         begin
          ejemplar.numero_titulo:=num_titulo;
          titulo:=buscar_titulo_numero(arch_tit,num_titulo);
          genero:=buscar_genero_numero(arch_gen,titulo.numero_genero);
          {pido el numero de pasillo y lo valido}
          write('Ingrese el numero de pasillo(1-10): ');
          readln(num_pasillo);
          writeln;
            while (num_pasillo<genero.ubicacion_desde.pasillo) or (num_pasillo>genero.ubicacion_hasta.pasillo) do
                   pasillo_no_valido (num_pasillo);
          ejemplar.pasillo:=num_pasillo;
          {pido el numero de estante y lo valido}
          write('Ingrese el numero de estante(1-15): ');
          readln(num_estante);
          writeln;
          estante_valido:=false;
            while not estante_valido do
               begin
                    if (num_estante>genero.ubicacion_hasta.estante) or (num_estante<genero.ubicacion_desde.estante) then
                        estante_no_valido (num_estante)
                    else
                        estante_valido:=true;
               end;
          ejemplar.estante:=num_estante;
          ejemplar.esta:=true;
          ejemplar.prestamo:=false;
          {ya esta todo validado, ingreso el ejemplar}
          insertado:= insertar_ejemplar(arch_ejem,ejemplar);
             if (insertado) then
               begin
                mensaje('         El ejemplar         ',' fue ingresado correctamente ');
                readkey;
               end;
         end;
      end;
 mensaje('Desea ingresar otro ejemplar?','            (S/N)            ');
 (resp):=readkey;
 until (resp= 'N') or (resp='n');
clrscr;
menu_principal
end;
         {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
           {REALIZA EL EGRESO DE UN EJEMPLAR DE LA BIBLIOTECA}
procedure egreso_ejemplar (var arch_ejem:tar_ejemplares);
var num_ejemplar:integer;
    eliminado:boolean;

begin
     write('Ingrese numero de ejemplar: ');
     readln(num_ejemplar);
     eliminado := sacar_ejemplar(arch_ejem,num_ejemplar);
     if (eliminado) then
        mensaje('       El ejemplar fue       ','   eliminado correctamente   ')
     else
        mensaje('    No hay ejemplares con    ',' ese c¢digo en la biblioteca ');
readkey;
mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal
end;

        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                {MOVIMIENTO DE UN EJEMPLAR PARTICULAR}


Procedure Movimiento_Ejemplar(var arejemplares:tar_ejemplares;var
                              artitulos:tar_titulos;
                              var argeneros:tar_generos);
  {pide al usuario un numero de ejemplar y lo mueve a otro estante
  que se indique ,si es posible}


   var
       destino:tr_ubicacion;
       numeroejemplar:integer;
       ejemplar:tr_ejemplar;
       titulo:tr_titulos;
       genero:tr_genero;
       generoestante:integer;
       posejemplar:longint;
   begin

     Repeat
      {pide datos al usuario}
      textcolor(white);
      textbackground(black);
      clrscr;
      cursoroff;
      gotoxy(25,5);
      textbackground(red);
      Write('MOVIMIENTO DE EJEMPLAR');
      textbackground(black);
      gotoxy(15,8);
      cursoron;

      write('Ingrese Numero de Ejemplar:');
      readln(numeroejemplar);

      gotoxy(15,10);
      write('Mover al pasillo...');
      read(destino.pasillo);

      gotoxy(15,12);
      write('Mover al Estante...');
      read(destino.estante);

      cursoroff;

      gotoxy(18,15);
      write('-----------------------------------');
      gotoxy(18,18);

      {busca la posicion en el archivo y lo carga a memoria}
      posejemplar:=pos_fis_ejemplar(arejemplares,numeroejemplar);

      if posejemplar<>-1 then

         begin
           seek(arejemplares,posejemplar);
           read(arejemplares,ejemplar);

           {titulo del ejemplar y genero del ejemplar}
           titulo:=(buscar_titulo_numero(artitulos,ejemplar.numero_titulo));
           genero:=(buscar_genero_numero(argeneros,titulo.numero_genero));

           {genero del estante destino}

generoestante:=Ver_genero_estante(argeneros,destino.pasillo,destino.estante);
         end;

      if posejemplar=-1 then writeln('El ejemplar especificado no existe')
      else
        if genero.numero<>generoestante then
          begin
           writeln('El genero del ejemplar no coincide ');
           gotoxy(18,19);
           writeln('       con el nuevo estante');
          end
         else
          begin
            ejemplar.pasillo:=destino.pasillo;
            ejemplar.estante:=destino.estante;
            seek(arejemplares,posejemplar);
            write(arejemplares,ejemplar);
          end;


      writeln;

      textcolor(red);

      writeln('          Cualquier tecla para NUEVO MOVIMIENTO / ESC:salir');


   Until #27=readkey;
   clrscr;
   menu_principal;
   end;


        {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
          {MODIFICACION EN LA UBICACION DE UN ESTANTE COMPLETO}

Procedure Cambio_Estantes (var arejemplares:tar_ejemplares;var
argeneros:tar_generos);
   {cambia estantes completos de un lugar a otro}
   {usa la funcion Ver_Genero_Estante}
   var
      ubidestino,ubiorigen:tr_ubicacion;
      generoorigen,generodestino:0..MAX_GENERO;
      ejemplartemp:tr_ejemplar;

   begin

   Repeat
    reset (arejemplares);
    reset(argeneros);
    {pide datos al usuario,e decir cuales son los estantes que se
    intercambian}

    textbackground(black);
    textcolor(white);
    clrscr;

    textbackground(red);
    gotoxy(25,5);
    write ('MOVIMIENTO DE ESTANTES');

    gotoxy(15,10);
    textbackground(black);
    cursoron;

    write('Desde pasillo Nß: ');
    readln(ubiorigen.pasillo);

    gotoxy(15,12);
    write('Desde estante Nß: ');
    readln(ubiorigen.estante);


    gotoxy(40,10);
    write('Hasta pasillo Nß: ');
    readln(ubidestino.pasillo);

    gotoxy(40,12);
    write('Hasta estante Nß: ');
    readln(ubidestino.estante);

    gotoxy(15,16);
    write('-------------------------------------------');
    gotoxy(15,18);

    {toma los generos de ambos estantes}

generoorigen:=Ver_Genero_Estante(argeneros,ubiorigen.pasillo,ubiorigen.estante);

generodestino:=Ver_Genero_Estante(argeneros,ubidestino.pasillo,ubidestino.estante);


    {verifica los generos de ambos estantes, y si son iguales
    hace el cambio}



         if (generodestino=generoorigen) then

            begin
             mover_estante(arejemplares,ubiorigen.pasillo,ubiorigen.estante,
                           ubidestino.pasillo,ubidestino.estante);

             writeln  ('    El movimiento se efectu¢ correctamente');
            end
         else
            begin
               write  ('  Los estantes no pueden intercambiarse ya que');
               gotoxy(15,19);
               writeln('           no coinciden los generos          ');
            end;


    textcolor(red);
    gotoxy(14,29);
    write('         Pulse cualquier tecla para NUEVO MOVIMIENTO / ESC:salir');

   until #27=readkey;
   clrscr;
   menu_principal;
   end;

{///////////////////////////////////////////////////////////////////}
procedure pant_ini_prestamo(var numejemplar,numsocio:integer);


   begin
        textbackground(black);
        textcolor(white);
        clrscr;

        textbackground(red);
        gotoxy(25,5);
        write ('PRESTAMO DE EJEMPLARES');

        gotoxy(15,10);
        textbackground(black);
        cursoron;

        {pide numero de socio}
        write('N£mero de socio: ');
        readln(numsocio);

        {pide numero de ejemplar}
        gotoxy(15,12);
        write('N£mero de ejemplar: ');
        readln(numejemplar);

   end;

procedure pant_fin_prestamo(resultoperacion:byte);
{recibe un codigo de resultado y muestra mensage}
   begin

    {codigos de resultado de prestamo
        1:prestamo correcto
        2:ejemplar en prestamo
        3:ejemplar no existe
        4:socio no existe}

    case resultoperacion of
      1:mensaje('         el prestamo         ','   se efectuo correctamente  ');
      2:mensaje('  el ejemplar se encuentra   ','         en prestamo         ');
      3:mensaje(' no existe un ejemplar con   ',' ese codigo en la biblioteca ');
      4:mensaje('     No hay socios con       ',' ese codigo en la biblioteca ');

    end;
    readkey;
   end;

{///////////////////////////////////////////////////////////////////}



        {********************************************************}
                  {REISTRA EL PRêSTAMO DE UN EJEMPLAR}

procedure prestamo(var arprestamos:tar_prestamos;var
                   arejemplares:tar_ejemplares;
                   var arsocios:tar_socios;fecha:longint);

   {pide un numero de ejemplar y numero de socio y realiza un prestamo}
   var
     ejemplartemp:tr_ejemplar;
     sociotemp:tr_socio;
     prestamotemp:tr_prestamo;
     numsocio,numejemplar:integer;
     posprestamo:longint;
     posejemplar:longint;

   begin

    repeat

        pant_ini_prestamo(numejemplar,numsocio);
        cursoroff;

        {busca el socio y ejemplar con esos numeros}
        posejemplar:=pos_fis_ejemplar(arejemplares,numejemplar);
        if posejemplar>=0 then
           begin
             seek(arejemplares,posejemplar);
             read(arejemplares,ejemplartemp);
           end;

        sociotemp:=buscar_socio_numero(arsocios,numsocio);


        gotoxy(15,18);

        {realiza el prestamo solo si existe el socio, el ejemplar no se
        encuentra prestado, y si el ejemplar existe}

        if sociotemp.numero<>0 then

                if posejemplar>=0 then

                        if (not ejemplartemp.prestamo) then

                           begin
                                {realiza el prestamo}

                                posprestamo:=buscar_lugar_prestamo(arprestamos);

                                {ingresa un nuevo prestamo en el archivo}
                                prestamotemp.esta:=true;
                                prestamotemp.num_ejemplar:=numejemplar;
                                prestamotemp.num_socio:=numsocio;
                                prestamotemp.fecha:=fecha;

                                seek(arprestamos,posprestamo);
                                write(arprestamos,prestamotemp);

                                {pone prestamo=true en el ejemplar}
                                ejemplartemp.prestamo:=true;
                                seek(arejemplares,posejemplar);
                                write(arejemplares,ejemplartemp);

                                {mensages de resultado para el usuario}
                                pant_fin_prestamo(1);
                           end

                        else  pant_fin_prestamo(2)
                else pant_fin_prestamo(3)
        else pant_fin_prestamo(4);

        mensaje('    NUEVO PRESTAMO (S/N)     ','                             ');

    until 'n'=readkey;

    clrscr;
    cursoron;
    menu_principal;

   end;

{///////////////////////////////////////////////////////////////////}
procedure pant_ini_devolucion(var nejemplar:integer);
    begin

      textbackground(black);
      textcolor(white);
      clrscr;

      textbackground(red);
      gotoxy(25,5);
      write ('DEVOLUCION DE EJEMPLARES');

      gotoxy(15,10);
      textbackground(black);
      cursoron;

      {pide numero de socio}
      write('N£mero de ejemplar: ');
      readln(nejemplar);

    end;

procedure pant_fin_devolucion(resultoperacion,atraso,numsocio:integer);
 {recibe un codigo de resltado y el atraso de la devolucion
  si corresponde y muestra el mensage}
   var
      cadena1,cadena2:string;
   begin
      case resultoperacion of
         1:
            begin
               cadena2:='        Socio nß: '+inttostr(numsocio)+'          ';
               mensaje('Ejemplar devuelto en termino ',cadena2);
            end;
         2:
            begin
               cadena1:='El socio '+inttostr(numsocio)+' se atraso  ';
               cadena2:=inttostr(atraso)+' d°as en la devolucion     ';
               mensaje(cadena1,cadena2);
            end;
         3:mensaje(' El ejemplar no se encuentra ','        en prestamo          ');
         4:mensaje('    El ejemplar no existe    ','                             ');
      end;
      readkey;
   end;


         {********************************************************}
                 {REGISTRA LA DEVOLUCI‡N DE UN EJEMPLAR}

procedure devolucion (var arejemplares:tar_ejemplares;
                      var arprestamos:tar_prestamos;
                      fecha:longint);

  {hace la devolucion de un ejemplar}

  const
        MAXDIAS=7;
  var
        numejemplar,atraso:integer;
        prestamotemp:tr_prestamo;
        ejemplartemp:tr_ejemplar;
        sociotemp:tr_socio;
        posejemplar,posprestamo:longint;

 begin

   repeat

    pant_ini_devolucion(numejemplar);
    cursoroff;

    posejemplar:=pos_fis_ejemplar(arejemplares,numejemplar);
    posprestamo:=pos_fis_prestamo(arprestamos,numejemplar);

    {si el pretamo existe pongo en el ejemplar prestamo=false
    y en el prestamo pongo esta=false}

    if posejemplar>=0 then

        if posprestamo>=0 then

           begin
              {modifico el ejemplar}
              seek(arejemplares,posejemplar);
              read(arejemplares,ejemplartemp);
              ejemplartemp.prestamo:=false;
              seek(arejemplares,posejemplar);
              write(arejemplares,ejemplartemp);

              {modifico el prestamo}
              seek(arprestamos,posprestamo);
              read(arprestamos,prestamotemp);
              prestamotemp.esta:=false;
              seek(arprestamos,posprestamo);
              write(arprestamos,prestamotemp);

              sociotemp:=buscar_socio_numero(arsocios,prestamotemp.num_socio);

              {verifica si el ejemplar fue devuelto dentro de el termino}
              atraso:=fecha-prestamotemp.fecha;

                     {codigos de resultado devolucion
                        para mensages de usuario
                        1:devolucion correcta
                        2:devolucion atrasada
                        3:no esta en prestamo
                        4:ejemplar no xiste}

              if atraso>MAXDIAS then pant_fin_devolucion(2,atraso-7,sociotemp.numero)
              else pant_fin_devolucion(1,0,sociotemp.numero);

           end

        else pant_fin_devolucion(3,0,0)
    else pant_fin_devolucion(4,0,0);

    mensaje('      Desea realizar una     ','   nueva decoluci¢n? (S/N)   ');

 until 'n'=readkey;

 cursoron;
 clrscr;
 menu_principal;
end;


         {********************************************************}
                     {MUESTRA LOS EJEMPLARES ADEUDADOS}


procedure lista_deudas (var ar_prestamo:tar_prestamos; var ar_titulos:tar_titulos;
                        var ar_socios:tar_socios;var ar_ejemplar:tar_ejemplares;
                        fecha: longint);
type tr_indice= record
                fecha: longint;
                pos: integer;
                end;
     tv_indice= array [1..100] of tr_indice;


procedure intercambio (var a,b:tr_indice);
var aux: tr_indice;
begin
 aux:=a;
 a:=b;
 b:=aux;
end;


procedure ordenar_listado (var vindice: tv_indice; cantdeudas: integer);

var
        i,j:integer;
        desordenado:boolean;

begin
desordenado:= true;
i:=1;
while ((desordenado) and (i<= (cantdeudas-1))) do
   begin
    desordenado:= false;
      for j:=1 to (cantdeudas-i) do
        if vindice[j].fecha>vindice[j+1].fecha then
          begin
            intercambio (vindice[j],vindice[j+1]);
            desordenado:= true;
      end;
    inc (i);
   end;
end;


procedure exportar_deudas (var ar_prestamo:tar_prestamos;
                           var ar_titulos:tar_titulos;
                           var ar_socios:tar_socios;
                           var ar_ejemplar:tar_ejemplares;
                           fecha: longint;cantdeudas:integer;
                           vindice:tv_indice);
var i: integer;
    prestamo: tr_prestamo;
    titulo: tr_titulos;
    socio: tr_socio;
    ejemplar: tr_ejemplar;
    csv_exportar:text;

begin
assign (csv_exportar,'deudas.csv');
rewrite (csv_exportar);
  for i:=1 to cantdeudas do
   begin
     seek (ar_prestamo,vindice[i].pos);
     read (ar_prestamo,prestamo);
     socio:=buscar_socio_numero (ar_socios,prestamo.num_socio);
     ejemplar:= buscar_ejemplar_numero (ar_ejemplar,prestamo.num_ejemplar);
     titulo:= buscar_titulo_numero (ar_titulos,ejemplar.numero_titulo);
     writeln (csv_exportar,prestamo.num_ejemplar,',',prestamo.num_socio,',',socio.nombre,',',titulo.nombre,',',fecha-prestamo.fecha-7);
   end;

close (csv_exportar);
mensaje('   Se ha exportado la lista  ','   en el archivo DEUDAS.CSV  ');
readkey;
end;



var prestamo: tr_prestamo;
    titulo: tr_titulos;
    socio: tr_socio;
    ejemplar: tr_ejemplar;
    i,j,cantdeudas: integer;
    vector_indice: tv_indice;
    deudas: boolean;
    car:char;

begin
    reset (ar_prestamo);
    cantdeudas:= 0;
    deudas:= false;
      for i:=0 to (filesize (ar_prestamo)-1) do
        begin
        seek (ar_prestamo,i);
        read (ar_prestamo,prestamo);
          if (fecha-prestamo.fecha-7>0) and (prestamo.esta) then
            begin
            seek (ar_prestamo,i);
            read (ar_prestamo,prestamo);
            inc (cantdeudas);
            vector_indice[cantdeudas].fecha:=prestamo.fecha;
            vector_indice[cantdeudas].pos:=i;
            deudas:= true;
            end;
        end;

  if not deudas then
  begin
     mensaje('      No hay ejemplares      ','  adeudados en la biblioteca ');
     readkey;
  end
  else
   begin
    ordenar_listado (vector_indice, cantdeudas);
     for j:=1 to cantdeudas do
       begin
       seek (ar_prestamo,vector_indice[j].pos);
       read (ar_prestamo,prestamo);
       socio:=buscar_socio_numero (ar_socios,prestamo.num_socio);
       ejemplar:= buscar_ejemplar_numero (ar_ejemplar,prestamo.num_ejemplar);
       titulo:= buscar_titulo_numero (ar_titulos,ejemplar.numero_titulo);
       writeln;
       writeln ('Numero de ejemplar : ',prestamo.num_ejemplar);
       writeln ('Numero de socio    : ',prestamo.num_socio);
       writeln ('Nombre de socio    : ',socio.nombre);
       writeln ('Nombre de titulo   : ',titulo.nombre);
       writeln ('Dias de atraso     : ',fecha-prestamo.fecha-7);
       writeln;
       end;

     repeat
     readkey;
     mensaje('  Desdea exportar el listado ','de deudas en un archivo?(S/N)');
     (car):=readkey;
     until (car='s') or (car='n');
      if car='s' then
        exportar_deudas (ar_prestamo,ar_titulos,ar_socios,ar_ejemplar,
        fecha,cantdeudas,vector_indice);
   end;

mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;

        {********************************************************}
    {MUESTRA UN MAPA DE LA BIBLIOTECA UBICANDO UN EJEMPLAR EN PARTICULAR}

        procedure mapa_ejemplares(pas,est:integer);

        var     i,pasillo:integer;

        begin
                dibujar_mapa;

                pasillo:=2;

                i:=1;

                while (i<=10) and (i<=pas) do
                begin
                   if pas=i then
                   begin
                      gotoxy(pasillo,est+1);
                      textbackground(7);
                      write('     ');
                   end;
                   pasillo:=pasillo+8;
                   inc(i);
                end;


                gotoxy(1,20);
                textbackground(7);
                write('   ');
                textbackground(black);
                write('  Ejemplar del pasillo ',pas,', estante ',est);
                readkey;
                mensaje('      Presione una tecla     ','para volver al men£ principal');
                readkey;
                clrscr;
                menu_principal;
        end;

        {********************************************************}
            {MUESTRA LOS EJEMPLARES DE UN TITULO EN PARTICULAR}

procedure vejemplares (var ar_titulos: tar_titulos; var ar_ejemplar: tar_ejemplares);
const espacio= ' ';
      esc= #27;
var codigo, pasillo, estante: integer;
    car: char;
    titulo: tr_titulos;
    ejemplar: tr_ejemplar;
    hay_ejemplares,hay_titulo: boolean;
begin
clrscr;
textbackground(red);
writeln ('VISUALIZACION DE EJEMPLARES');
textbackground(black);
writeln;
write ('Ingrese el codigo de titulo: ');
readln (codigo);
writeln;
writeln;
hay_ejemplares:= false;
hay_titulo:=false;

reset (ar_titulos);

titulo:=buscar_titulo_numero(ar_titulos,codigo);

if titulo.numero=0 then
begin
   mensaje('      No hay t°tulos con     ',' ese c¢digo en la biblioteca ');
   readkey;
end
else
begin
  hay_titulo:=true;
  reset(ar_ejemplar);
  while not eof(ar_ejemplar) do
  begin
     read(ar_ejemplar,ejemplar);
     if (ejemplar.numero_titulo=codigo) and (ejemplar.esta) then
     begin
        write ('Numero de ejemplar ',ejemplar.numero);
        write(' en el pasillo ',ejemplar.pasillo);
        write (' en el estante ',ejemplar.estante);
        writeln;
        hay_ejemplares:=true;
     end;
  end;
end;


if (not hay_ejemplares) and (hay_titulo) then
begin
   mensaje('     No hay ejemplares de    ',' ese t°tulo en la biblioteca ');
   readkey;
end
 else
 begin
 if (hay_ejemplares) and (hay_titulo) then
 begin
 writeln;
 writeln;
 writeln;
 Writeln ('Si desea visualizar un ejemplar en el mapa de la biblioteca: ');
 writeln ('Pulse la barra espaciadora');
 writeln;
 writeln ('Para salir presione cualquier tecla');
 car:= readkey;
 if car = espacio then
  begin
    clrscr;
    textbackground(red);
    writeln ('VISUALIZACI‡N DE EJEMPLAR EN MAPA');
    textbackground(black);
    writeln;
    write ('Ingrese pasillo: ');
    readln (pasillo);
    writeln;
    write ('Ingrese estante: ');
    readln (estante);
    clrscr;
    mapa_ejemplares (pasillo, estante);
  end;
  end;
 end;

mensaje('      Presione una tecla     ','para volver al men£ principal');
readkey;
clrscr;
menu_principal;
end;


         {*******************************************************}
         {*******************************************************}

                             {MODO TEST}

         {*******************************************************}
         {*******************************************************}

procedure modo_test (var fecha:longint);
  {no entendi muy bien que hace el modo test,
  pero este procedimiento permite al usuario
  cambiar la fecha con la que trabaja el programa}
  var
    annio,mes,dia:integer;
    opc:char;
  begin

    textbackground(black);
    textcolor(white);
    clrscr;

    textbackground(red);
    gotoxy(35,5);
    write('MODO TEST');
    gotoxy(10,10);
    textbackground(black);
    cursoroff;

    write('1- Fecha de hoy');
    gotoxy(10,13);
    write('2- Cambiar fecha ');


    opc:=readkey;

    if opc='1' then cargar_fecha_sistema(fecha);

    if opc='2' then
      begin
        clrscr;
        textbackground(red);
        gotoxy(35,5);
        write('MODO TEST');
        gotoxy(10,10);
        textbackground(black);
        cursoron;

        write('D°a: ');
        read(dia);

        gotoxy(10,12);
        write('Mes: ');
        read(mes);

        gotoxy(10,14);
        write('A§o: ');
        read(annio);

        fecha:=((annio*10000)+(mes*100)+dia);

        cursoroff;
        mensaje('       Los datos fueron      ','   procesados correctamente  ');
        readkey;
      end;

    mensaje('      Presione una tecla     ','para volver al men£ principal');
    readkey;
    clrscr;
    menu_principal;
  end;


           {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
           {}                                                     {}
           {}                 {MENÈES Y SUBMENÈES}                {}
           {}                                                     {}
           {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
             {SUBMENU DE ALTA Y BAJA DE TITULOS, AUTORES Y SOCIOS}

        procedure menu_tit_autor(op:char);

        var     opc:char;
        begin
                menu_dinam('   Titulo     ',' Autor   ',' Socio  ');

                delay(100);
                gotoxy(41,1);
                textbackground(white);
                textcolor(blue);
                write(' 4 ');
                textbackground(red);
                textcolor(white);
                write(' Volver al men£ principal   ');
                textbackground(black);


                (opc):=readkey;

                if op='1' then
                begin
                        case (opc) of
                                '1':begin
                                        alta_titulo(artitulos,arautores);
                                    end;
                                '2':begin
                                        alta_autor(arautores,indice_autores);
                                    end;
                                '3':begin
                                        alta_socio(arsocios);
                                    end;
                                '4':begin
                                        clrscr;
                                        menu_principal;
                                    end;

                                else
                                begin
                                        mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                        readkey;
                                        clrscr;
                                        menu_tit_autor(op);
                                end;
                        end;
                end;


                if op='2' then
                begin
                        case (opc) of
                                '1':begin
                                        textbackground(black);
                                        baja_titulo(artitulos,arejemplares);
                                    end;
                                '2':begin
                                        textbackground(black);
                                        baja_autor(arautores,artitulos);
                                    end;
                                '3':begin
                                        textbackground(black);
                                        baja_socio(arsocios,arprestamos);
                                    end;
                                '4':begin
                                        textbackground(black);
                                        clrscr;
                                        menu_principal;
                                    end;

                                else
                                begin
                                        mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                        readkey;
                                        clrscr;
                                        menu_tit_autor(op);
                                end;
                         end;
                end;
        end;

         {********************************************************}

       {SUBMENU DE MODIFICACI‡N DE ESTANTES Y EJEMPLARES PARTICULARES}

       procedure menu_est_ejem;

       var      opc:char;

       begin
                menu_dinam('  Ejemplar    ',' Estante ',' Volver al men£ principal ');
                opc:=readkey;
                case (opc) of
                        '1': begin
                                movimiento_ejemplar(arejemplares,artitulos,argeneros);
                             end;
                        '2': begin
                                cambio_estantes(arejemplares,argeneros);
                             end;
                        '3': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                        begin
                                mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;
                                menu_est_ejem;
                        end;
                end;
        end;

         {********************************************************}

             {SUBMENU DE MODIFICACI‡N DE EJEMPLARES Y GêNEROS}

        procedure menu_gen_ejem;

        var     opc:char;

        begin
                menu_dinam('  Ejemplares  ',' GÇneros ',' Volver al men£ principal ');
                opc:=readkey;
                case (opc) of
                        '1': begin
                                menu_est_ejem;
                             end;
                        '2': begin
                                modificar_genero(arejemplares,argeneros);
                             end;
                        '3': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                        begin
                                mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;
                                menu_gen_ejem;
                        end;
                end;
        end;


          {********************************************************}

            {SUBMENU DE MODIFICACI‡N DE TITULOS, AUTORES Y SOCIOS}

        procedure menu_aut_tit;

        var     opc:char;

        begin
                menu_dinam('   Titulo     ',' Autor   ',' Socio  ');

                delay(100);
                gotoxy(41,1);
                textbackground(white);
                textcolor(blue);
                write(' 4 ');
                textbackground(red);
                textcolor(white);
                write(' Volver al men£ principal   ');
                textbackground(black);

                opc:=readkey;
                case (opc) of
                        '1': begin
                                modificar_titulos(artitulos);
                             end;
                        '2': begin
                                modificar_autor(arautores,indice_autores);
                             end;
                        '3': begin
                                modificar_socios(arsocios);
                             end;
                        '4': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                        begin
                                mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;
                                menu_aut_tit;
                        end;
                end;
        end;

          {********************************************************}

                   {SUBMENU DE MODIFICACIONES GENERALES}

        procedure menu_modificacion;

        var     opc:char;

        begin
                menu_dinam(' Ubicaci¢n    ',' Datos   ',' Volver al men£ principal ');
                opc:=readkey;
                case (opc) of
                        '1': begin
                                menu_gen_ejem;
                             end;
                        '2': begin
                                menu_aut_tit;
                             end;
                        '3': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                        begin
                                mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;
                                menu_modificacion;
                        end;
                end;
        end;

          {********************************************************}

                 {SUBMENÈ DE IMPORTACION DE AUTORES O TITULOS}

        procedure menu_imp_tit_autor;

        var     opc:char;

        begin
                menu_dinam('   Titulo     ',' Autor   ',' Volver al men£ principal ');
                opc:=readkey;
                case (opc) of
                        '1': begin
                                imp_titulos_csv(artitulos,arautores,indice_autores);
                             end;
                        '2': begin
                                imp_autores_csv(arautores,fecha,indice_autores);
                             end;
                        '3': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                        begin
                                mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;
                                menu_modificacion;
                        end;
                end;
        end;


          {********************************************************}

                    {SUBMENU DE ALTA, BAJA Y MODIFICACI‡N}

        procedure menu_abm;

        var     i:byte;
                opc:char;

        begin
                gotoxy (4,2);
                delay(30);
                textbackground (white);
                textcolor(blue);
                write(' 1 ');
                textbackground (red);
                textcolor(white);
                writeln('  Alta          ');
                gotoxy(4,3);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 2 ');
                textbackground(red);
                textcolor(white);
                writeln('  Baja          ');
                gotoxy(4,4);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 3 ');
                textbackground(red);
                textcolor(white);
                writeln('  Modificaci¢n  ');
                gotoxy(4,5);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 4 ');
                textbackground(red);
                textcolor(white);
                writeln('  Importaci¢n   ');
                gotoxy(4,6);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 5 ');
                textbackground(red);
                textcolor(white);
                writeln('  Volver        ');

                (opc):=readkey;
                case (opc) of
                       '1': begin menu_tit_autor(opc); end;
                       '2': begin menu_tit_autor(opc); end;
                       '3': begin menu_modificacion; end;
                       '4': begin menu_imp_tit_autor; end;
                       '5': begin
                                textbackground (black);
                                clrscr;
                                menu_principal;
                             end;
                       else
                                begin
                                  mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                  readkey;
                                  clrscr;
                                  menu_principal;
                       end;
                end;
        end;

          {********************************************************}
                    {SUMENÈ DE PRêSTAMOS Y DEVOULUCIONES}

        procedure menu_prestamo_devolucion;

        var     opc:char;

        begin
                menu_dinam(' Devoluci¢n   ',' Prestar  ',' Volver al men£ principal ');

                opc:=readkey;
                case (opc) of
                       '1': begin
                                devolucion(arejemplares,arprestamos,fecha);
                             end;
                        '2': begin
                                prestamo(arprestamos,arejemplares,arsocios,fecha);
                             end;
                        '3': begin
                                clrscr;
                                menu_principal;
                             end;

                        else
                        begin
                                mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                readkey;
                                clrscr;
                                menu_prestamo_devolucion;
                        end;
                end;
        end;

          {********************************************************}

                       {SUBMENU DE INGRESOS Y EGRESOS}

        procedure menu_ingresos_egresos;

        var     i:byte;
                opc:char;

        begin
                gotoxy(16,2);
                delay(30);
                textbackground (white);
                textcolor(blue);
                write(' 1 ');
                textbackground(red);
                textcolor(white);
                write('  Ingresos  ');
                gotoxy(16,3);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 2 ');
                textbackground(red);
                textcolor(white);
                write('  Egresos   ');
                gotoxy(16,4);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 3 ');
                textbackground(red);
                textcolor(white);
                write('  PrÇstamos ');
                gotoxy(16,5);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 4 ');
                textbackground(red);
                textcolor(white);
                write('  Volver    ');
                (opc):=readkey;
                case (opc) of
                        '1': begin
                                textbackground(black);
                                clrscr;
                                ingreso_ejemplar(arejemplares,artitulos,argeneros);
                             end;
                        '2': begin
                                textbackground(black);
                                clrscr;
                                egreso_ejemplar(arejemplares);
                             end;
                        '3': begin menu_prestamo_devolucion; end;
                        '4': begin
                                textbackground (black);
                                clrscr;
                                menu_principal;
                             end;
                        else
                        begin
                          mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                          readkey;
                          clrscr;
                          menu_principal;
                        end;
                end;
        end;

          {********************************************************}

             {SUBMENU DE VISUALIZACIONES INDIVIDUALES O GENERALES}

procedure menu_indiv_todos(op:char);

var     opc:char;

begin
        menu_dinam(' Individual   ',' Todos   ',' Volver al men£ principal ');

        (opc):=readkey;

        if op='1' then
        begin
                case (opc) of
                        '1':begin
                                textbackground(black);
                                clrscr;
                                vaut_ind(arautores,artitulos,indice_autores);
                            end;
                        '2':begin
                                textbackground(black);
                                visualizar_autores(arautores);
                            end;
                        '3':begin
                                clrscr;
                                menu_principal;
                            end;
                        else
                        begin
                          mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                          readkey;
                          clrscr;
                          menu_indiv_todos(op);
                        end;
                end;
        end;


        if op='2' then
        begin
                case (opc) of
                        '1':begin
                                textbackground(black);
                                clrscr;
                                vtit_ind(artitulos);
                             end;
                        '2':begin
                                textbackground(black);
                                visualizar_titulos(artitulos);
                            end;
                        '3':begin
                                clrscr;
                                menu_principal;
                            end;
                        else
                        begin
                          mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                          readkey;
                          clrscr;
                          menu_indiv_todos(op);
                        end;
                end;
        end;


        if op='3' then
        begin
                case (opc) of
                        '1':begin
                                textbackground(black);
                                vgen_ind(artitulos,argeneros);
                            end;
                        '2':begin
                                textbackground(black);
                                visualizar_generos(argeneros);
                            end;
                        '3':begin
                                clrscr;
                                menu_principal;
                            end;
                        else
                        begin
                          mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                          readkey;
                          clrscr;
                          menu_indiv_todos(op);
                        end;
                end;
        end;


end;

          {********************************************************}

        procedure menu_ejem_ind_adeuda;

        var     opc:char;

        begin

                menu_dinam(' De un t°tulo ',' Deudas  ',' Volver al men£ principal ');

                opc:=readkey;

                case (opc) of
                        '1': begin vejemplares(artitulos,arejemplares); end;
                        '2': begin
                                clrscr;
                                lista_deudas(arprestamos,artitulos,arsocios,arejemplares,fecha);
                             end;
                        '3':begin clrscr; menu_principal; end;

                        else
                        begin
                          mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                          readkey;
                          clrscr;
                          menu_ejem_ind_adeuda;
                        end;
                end;
        end;

          {********************************************************}

                          {SUBMENU DE VISUALIZACIONES}

        procedure menu_ver;

        var     i:byte;
                opc:char;

        begin
                gotoxy(43,2);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 1 ');
                textbackground(red);
                textcolor(white);
                write(' Autores      ');
                gotoxy(43,3);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 2 ');
                textbackground(red);
                textcolor(white);
                write(' Titulos      ');
                gotoxy(43,4);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 3 ');
                textbackground(red);
                textcolor(white);
                write(' GÇneros      ');
                gotoxy(43,5);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 4 ');
                textbackground(red);
                textcolor(white);
                write(' Ejemplares   ');
                gotoxy(43,6);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 5 ');
                textbackground(red);
                textcolor(white);
                write(' Socios       ');
                gotoxy(43,7);
                delay(30);
                textbackground(white);
                textcolor(blue);
                write(' 6 ');
                textbackground(red);
                textcolor(white);
                write(' Volver       ');
                (opc):=readkey;
                case (opc) of
                        '1': begin menu_indiv_todos(opc); end;
                        '2': begin menu_indiv_todos(opc); end;
                        '3': begin menu_indiv_todos(opc); end;
                        '4': begin
                                   clrscr;
                                   menu_ejem_ind_adeuda;
                             end;
                        '5': begin
                                textbackground(black);
                                ver_socios(arsocios,arprestamos);
                             end;
                        '6': begin
                                textbackground(black);
                                clrscr;
                                menu_principal;
                             end;
                        else
                        begin
                          mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                          readkey;
                          clrscr;
                          exit;
                          menu_principal;
                        end;

                end;
        end;

          {********************************************************}

                             {MENU PRINCIPAL}

var     i:byte;
        col,fil:integer;
        opc1,opc2:char;

begin
        cursoroff;
        textbackground (white);
        textcolor(blue);
        write(' 1 ');
        textbackground (red);
        textcolor(white);
        write('  ABM     ');
        gotoxy(14,1);
        textbackground(white);
        textcolor(blue);
        write(' 2 ');
        textbackground(red);
        textcolor(white);
        write('  Ingresos y Egresos    ');
        gotoxy(41,1);
        textbackground(white);
        textcolor(blue);
        write(' 3 ');
        textbackground(red);
        textcolor(white);
        write('  Ver     ');
        gotoxy(54,1);
        textbackground(white);
        textcolor(blue);
        write(' 4 ');
        textbackground(red);
        textcolor(white);
        write('  Mapa     ');
        gotoxy(68,1);
        textbackground(white);
        textcolor(blue);
        write(' 5 ');
        textbackground(red);
        textcolor(white);
        write('  Salir   ');
        textbackground (black);
        gotoxy(1,25);
        textbackground(red);
        write(' Para ejecutar el Modo Test presione la tecla `TÔ');


        (opc1):=readkey;
        case (opc1) of
               '1':begin menu_abm; end;
               '2':begin menu_ingresos_egresos; end;
               '3':begin menu_ver; end;
               '4':begin
                        textbackground(black);
                        clrscr;
                        mapa_general(argeneros);
                   end;
               '5':begin
                        mensaje('  Desea salir del programa?  ','            (S/N)            ');
                        (opc2):=readkey;
                        case (opc2) of
                                's': begin exit; end;
                                'n': begin
                                        textbackground(black);
                                        clrscr;
                                        menu_principal;
                                     end;
                                else
                                begin
                                  mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                                  readkey;
                                  clrscr;
                                  menu_principal;
                                end;
                        end;
                   end;
               't':begin modo_test(fecha); end;

               else
               begin
                 mensaje('      Opci¢n no valida!!     ','   Presione cualquier tecla  ');
                 readkey;
                 clrscr;
                 menu_principal;
               end;
        end;
end;

{****************************************************************************}

                         {CUERPO DEL PROGRAMA PRINCIPAL}

begin

   cargar_fecha_sistema(fecha);

  {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
        {Iinicializa los archivos que se van a usar}

   Ini_Archivos(artitulos,arautores,argeneros,arejemplares,arsocios,
                arprestamos,DIRTITULOS,DIRAUTORES,DIRPRESTAMOS,DIRGENEROS,
                DIREJEMPLARES,DIRSOCIOS);

   armar_ind_autores(arautores,indice_autores);
   ordenar_indice(indice_autores);
   {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}

   clrscr;

   menu_principal;

   clrscr;


   {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
                  {Cierra los archivos}
   Cerrar_Archivos(artitulos,arautores,argeneros,arejemplares,arsocios,
                  arprestamos);
   {≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠≠}

end.



