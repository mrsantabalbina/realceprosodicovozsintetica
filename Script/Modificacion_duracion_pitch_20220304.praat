###############################################################################
#	Modificación de duración y pitch de un intervalo en base a un TextGrid
#
#	Maria Ruiz Santabalbina
#	mrsantabalbina@gmail.com
#	
#   Reconocimientos:
#	Algunas partes están extraidas de diferentes scripts de Shigeto Kawahara
#	http://user.keio.ac.jp/~kawahara/pdf/PraatScriptingDummies.pdf
#
#	RECOMENDACIONES:
#	- Todos los archivos *.wav deben estar en la misma carpeta que el script
#   - En este caso, los textgrids tienen anotados intervalos con la etiqueta "stress" en un único tier
#
#	¿Necesitas este script?
#	Úsalo, cópialo, destrípalo. Ahora también es tuyo.
###############################################################################

#formulario para confirmar el directorio de entrada

form Files
	comment Carpeta de entrada
	text input_directory ./

endform

# se crea un directorio donde se guardarán los archivos *.wav resultantes
createDirectory ("output")

# lee todos los archivos en el directorio que se ha especificado en el formulario

Create Strings as file list... wavlist 'input_directory$'*.wav
Create Strings as file list... gridlist 'input_directory$'*.TextGrid
number_of_files = Get number of strings

# recorremos los archivos

for i from 1 to number_of_files

# Primero creamos un archivo tipo manipulation para cada archivo wav
	select Strings wavlist
	filename$ = Get string... i
	Read from file... 'input_directory$'/'filename$'
	soundname$ = selected$ ("Sound")
	# estos son los valores por defecto, pero puede modificarse si es necesario
    To Manipulation... 0.01 75 600
# y extraemos el pitch tier
	Extract pitch tier

# Ahora leemos los Textgrids...
	select Strings gridlist
	gridname$ = Get string... i
	Read from file... 'input_directory$'/'gridname$'
	#esto nos ayuda a saber cuántos intervalos hay en el tier 1 del textgrid
	#(aunque siempre serán 3, solo uno de ellos anotado)
	number_of_intervals = Get number of intervals... 1

	# este loop nos va ayudar a sacar los tiempos de los intervalos "stress" del textgrid
	for j from 1 to number_of_intervals
		#seleccionamos el textgrid
		select TextGrid 'soundname$'
		#1 es el número del tier que, en este caso además, es el único
		label$ = Get label of interval... 1 'j'
		# "stress" es la etiqueta de los intervalos que queremos mirar en los textgrids
		if label$ = "stress"
		#aquí cogemos el fragmento que necesitamos en base al textgrid
			onset = Get starting point... 1 'j'
			offset = Get end point... 1 'j'
		endif
	endfor
		
	#aquí cogemos el archivo pitchtier y aplicamos las modificaciones necesarias
	select PitchTier 'soundname$'
	# para la tesis se cambia el tercer campo con los siguientes valores:
	# 1 (baseline), 1.05 1.10, 1.15 1.20
	Multiply frequencies: onset, offset, 1	

	#seleccionamos los archivos manipulation y pitchier y cambiamos el tier de pitch
	select Manipulation 'soundname$'
	plus PitchTier 'soundname$'
	Replace pitch tier
		
	#seleccionamos el textgrid para modificar la duración
	select TextGrid 'soundname$'
	#creamos el durationtier a partir de la etiqueta "stress"
	#el segundo campo es la proporción en la que vamos a modificar la duración
	# para la tesis se cambia el segundo campo con los siguientes valores:
	# 1=baseline; 1.2, 1.4, 1.6, 1.8, 2
	To DurationTier: 1, 1, 1e-10, 1e-10, "is equal to", "stress"

	#seleccionamos los archivos manipulation y durationtier y cambiamos el tier de duration
	select Manipulation 'soundname$'
	plus DurationTier 'soundname$'
	Replace duration tier

	#resitentizamos el archivo manipulation y lo guardamos como .wav
	select Manipulation 'soundname$'
	Get resynthesis (PSOLA)
	Write to WAV file... ./output/'soundname$'.wav
	
endfor
#si se comentan estas dos últimas líneas, se ven en Praat todos los archivos que se han ido generando
select all
Remove