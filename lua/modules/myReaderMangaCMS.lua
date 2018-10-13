function GetNameAndLink()
  local u = module.RootURL
  if module.Website == 'WhiteCloudPavilion' then
    u = u .. '/manga/free'
  end
  if module.Website == 'GodsRealmScan' then
    u = u .. '/public/'
  end    
  u = u .. '/changeMangaList?type=text'
  if http.GET(u) then
    x = TXQuery.Create(http.Document)
    x.XPathHREFAll('//li/a', links, names)
    return no_error
  else
    return net_problem
  end
end

function GetInfo();
  mangainfo.url = MaybeFillHost(module.RootURL, url)
  if http.GET(mangainfo.url) then
    x = TXQuery.Create(http.Document)
    mangainfo.coverLink = MaybeFillHost(module.RootURL, x.XPathString('//div[@class="boxed"]/img/@src'))
    if mangainfo.title == '' then 
      mangainfo.title = x.XPathString('//h2[contains(@class,"widget-title")]')
      if mangainfo.title == '' then
        mangainfo.title = mangainfo.url:match('/([^/]+)$')
      end
    end
    if module.Website == 'MangaDenizi' then
      mangainfo.status = MangaInfoStatusIfPos(x.XPathString('//dt[.="Durum:"]/following-sibling::dd[1]'), 'Devam Ediyor', 'Tamamlandı')
    else
      mangainfo.status = MangaInfoStatusIfPos(x.XPathString('//dt[.=("Status","Estado")]/following-sibling::dd[1]'))
    end
    mangainfo.authors = x.XPathStringAll('//dt[.=("Author(s)","Yazar & Çizer:","Autor(es)")]/following-sibling::dd[1]/string-join(*,", ")')
    mangainfo.artists = x.XPathStringAll('//dt[.="Artist(s)"]/following-sibling::dd[1]/string-join(*,", ")')
    mangainfo.genres = x.XPathStringAll('//dt[.=("Categories","Kategoriler:","Categorías")]/following-sibling::dd[1]/string-join(*,", ")')
    mangainfo.summary = x.XPathString('//div[@class="well"]/p')
    v = x.Xpath('//ul[@class="chapters"]/li/*[self::h5 or self::h3]')
    for i = 1, v.Count do
      v2 = v.Get(i)
      mangainfo.chapterLinks.Add(x.XPathString('a/@href', v2))
      mangainfo.chapterNames.Add(x.XPathString('normalize-space(.)', v2))
    end
    InvertStrings(mangainfo.chapterLinks, mangainfo.chapterNames)
    return no_error
  else
    return net_problem
  end
end

function GetPageNumber()
  local u = MaybeFillHost(module.RootURL, url)
  if http.GET(u) then
    x = TXQuery.Create(http.Document)
    x.XPathStringAll('//div[@id="all"]/img/@data-src', task.PageLinks)
    if task.PageLinks.Count == 0 then
      x.XPathStringAll('//div[@id="all"]/img/@src', task.PageLinks)
    end
    task.pagecontainerlinks.text = u
    return true
  else
    return false
  end
end

function beforedownloadimage()
  http.reset()
  http.headers.values['Referer'] = task.pagecontainerlinks.text
  print(http.headers.values['Referer'])
  return true
end

function AddWebsiteModule(name, url, cat)
  local m = NewModule()
  m.category = cat
  m.Website = name
  m.RootURL = url
  m.LastUpdated = 'February 12, 2018'
  m.OnGetNameAndLink = 'GetNameAndLink'
  m.OnGetInfo = 'GetInfo'
  m.OnGetPageNumber = 'GetPageNumber'
  m.onbeforedownloadimage='beforedownloadimage'
  return m
end

function Init()
  local c='Spanish'
  AddWebsiteModule('MangaDoor', 'http://mangadoor.com', c);
  AddWebsiteModule('MangAs', 'https://mang.as', c);
  
  c='Indonesian'
  AddWebsiteModule('Komikid', 'http://www.komikid.com', c);
  AddWebsiteModule('MangaID', 'http://mangaid.net', c);
  AddWebsiteModule('KomikGue', 'https://www.komikgue.com', c);
  
  c='Raw'
  AddWebsiteModule('RawMangaUpdate', 'http://rawmangaupdate.com', c);
  AddWebsiteModule('MangaRawOnline', 'http://mangaraw.online', c);
  AddWebsiteModule('RawMangaSite', 'https://rawmanga.site', c);
  
  c='Turkish'
  AddWebsiteModule('MangaDenizi', 'http://www.mangadenizi.com', c);
  AddWebsiteModule('ManhuaTr', 'http://manhua-tr.com', c);
  AddWebsiteModule('MangaVadisi', 'http://manga-v2.mangavadisi.org', c);

  c='English-Scanlation'
  AddWebsiteModule('FallenAngelsScans','http://manga.fascans.com', c);
  AddWebsiteModule('ChibiManga','http://www.cmreader.info', c);
  AddWebsiteModule('WhiteCloudPavilion','https://whitecloudpavilion.com', c);
  AddWebsiteModule('HatigarmScans', 'https://www.hatigarmscans.net', c)

  c='Spanish-Scanlation'
  AddWebsiteModule('DarkSkyScan', 'http://darkskyprojects.org', c);
  AddWebsiteModule('NozominoFansub', 'https://nozominofansub.com', c);
  AddWebsiteModule('GodsRealmScan', 'https://godsrealmscan.com', c); 
  AddWebsiteModule('CoYuHi', 'http://www.universoyuri.com', c);
  AddWebsiteModule('SOSScanlation', 'http://sosscanlation.com', c);
end
