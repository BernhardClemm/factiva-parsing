# Parsing output from Factiva

Factiva is a great resource for working with past news articles. Which does not mean it's practical to use. As [others](https://philreeddata.wordpress.com/2016/05/20/extracting-meta-data-from-factiva-to-csv-via-python/) [have](http://seenanotherway.com/facteaser/) noted, exporting search results to some processable format like csv is tedious: Your options are a PDF (not structured well enough for online converters), an RTF (again no luck with online converters) or HTML. There is an R package called `tm.plugin.factiva` but it did not work for the HTML I downloaded. Here's an `R` function that does the job, relying on rvest. 

## Output

The function's output is a dataframe with each row representing an article, and the columns:
- headline 
- author (if present)
- news source
- number of words
- date of publication
- hour of publication (if present)
- some id of source 
- some number (unsure what it represents)
- language
- copyright holder,
- text

## Input

I am not entirely sure how stable the HTML format Factiva exports is. As the HTML I exported does not even use classes, the function is very sensitive to changes in the format. Here is a snippet of what the HTML containing the articles should more or less look like:

```
<div id="article-pnp0000020010926du4i003v3" class="article" >
	<div class="article deArticle">
		<p>
			<div id="hd" ><span class='deHeadline'> MEINUNG.ZU 50 JAHRE ISRAEL.</span>
			</div>
			<div>664 Wörter
			</div>
			<div>18 April 1998
			</div>
			<div>Passauer Neue Presse</div>
			<div>PNP
			</div>
			<div>Deutsch
			</div>
			<div>(c) 1998 Passauer Neue Presse, Neue Presse Verlags-GmbH
			</div>
		</p>
		<p class="articleParagraph dearticleParagraph">First paragraph...
		</p>
		<p class="articleParagraph dearticleParagraph">Second paragraph...
		</p>
		<p>Dokument pnp0000020010926du4i003v3
		</p>
	</div>
</div><br/><span></span>
<div id="article-sddz000020010927du5900a1e" class="article" >
	<div class="article deArticle">
		<p>
			<div id="hd" >
				<span class='deHeadline'>Fragen an das Land von Dani, Rami und Uzi.</span>
			</div>
			<div>2029 Wörter
			</div>
			<div>9 Mai 1998
			</div>
			<div>Süddeutsche Zeitung
			</div>
			<div>SDDZ
			</div>
			<div>18
			</div>
			<div>Deutsch
			</div>
			<div>(c) 1998 Süddeutsche Zeitung
			</div>
		</p>
		<p class="articleParagraph dearticleParagraph"> Große Erwartungen, große Enttäuschungen: Warum <b>Israel Kritik</b> von außen ungern hört / Von Amos Oz
		</p>
		<p class="articleParagraph dearticleParagraph"> First paragraph...
		</p>
		<p class="articleParagraph dearticleParagraph"> Second paragraph... </p>
		<p>Dokument sddz000020010927du5900a1e
		</p>
	</div>
</div><br/><span></span>

```
## Example

Using the above HTML snippet stored in the repository:

```
output_df <- factiva_parser("/Users/bernhardclemm/Dropbox/Academia/Apps/factiva-parsing/Factiva-example.html")
```
