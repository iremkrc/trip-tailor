class CityLocationModel {
  String? name;
  LocalNames? localNames;
  double? lat;
  double? lon;
  String? country;

  CityLocationModel(
      {this.name, this.localNames, this.lat, this.lon, this.country});

  CityLocationModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    localNames = json['local_names'] != null
        ? LocalNames.fromJson(json['local_names'])
        : null;
    lat = json['lat'];
    lon = json['lon'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (localNames != null) {
      data['local_names'] = localNames!.toJson();
    }
    data['lat'] = lat;
    data['lon'] = lon;
    data['country'] = country;
    return data;
  }
}

class LocalNames {
  String? sr;
  String? os;
  String? mk;
  String? hy;
  String? sv;
  String? ar;
  String? ur;
  String? th;
  String? pt;
  String? bn;
  String? fa;
  String? no;
  String? pl;
  String? ja;
  String? tg;
  String? zh;
  String? kk;
  String? ru;
  String? ps;
  String? uk;
  String? tr;
  String? nl;
  String? ml;
  String? mr;
  String? fr;
  String? ku;
  String? en;
  String? hi;
  String? ce;
  String? ta;
  String? el;
  String? es;
  String? de;
  String? ne;
  String? hu;
  String? it;
  String? ko;
  String? he;
  String? ug;
  String? kn;
  String? ka;

  LocalNames(
      {this.sr,
      this.os,
      this.mk,
      this.hy,
      this.sv,
      this.ar,
      this.ur,
      this.th,
      this.pt,
      this.bn,
      this.fa,
      this.no,
      this.pl,
      this.ja,
      this.tg,
      this.zh,
      this.kk,
      this.ru,
      this.ps,
      this.uk,
      this.tr,
      this.nl,
      this.ml,
      this.mr,
      this.fr,
      this.ku,
      this.en,
      this.hi,
      this.ce,
      this.ta,
      this.el,
      this.es,
      this.de,
      this.ne,
      this.hu,
      this.it,
      this.ko,
      this.he,
      this.ug,
      this.kn,
      this.ka});

  LocalNames.fromJson(Map<String, dynamic> json) {
    sr = json['sr'];
    os = json['os'];
    mk = json['mk'];
    hy = json['hy'];
    sv = json['sv'];
    ar = json['ar'];
    ur = json['ur'];
    th = json['th'];
    pt = json['pt'];
    bn = json['bn'];
    fa = json['fa'];
    no = json['no'];
    pl = json['pl'];
    ja = json['ja'];
    tg = json['tg'];
    zh = json['zh'];
    kk = json['kk'];
    ru = json['ru'];
    ps = json['ps'];
    uk = json['uk'];
    tr = json['tr'];
    nl = json['nl'];
    ml = json['ml'];
    mr = json['mr'];
    fr = json['fr'];
    ku = json['ku'];
    en = json['en'];
    hi = json['hi'];
    ce = json['ce'];
    ta = json['ta'];
    el = json['el'];
    es = json['es'];
    de = json['de'];
    ne = json['ne'];
    hu = json['hu'];
    it = json['it'];
    ko = json['ko'];
    he = json['he'];
    ug = json['ug'];
    kn = json['kn'];
    ka = json['ka'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sr'] = sr;
    data['os'] = os;
    data['mk'] = mk;
    data['hy'] = hy;
    data['sv'] = sv;
    data['ar'] = ar;
    data['ur'] = ur;
    data['th'] = th;
    data['pt'] = pt;
    data['bn'] = bn;
    data['fa'] = fa;
    data['no'] = no;
    data['pl'] = pl;
    data['ja'] = ja;
    data['tg'] = tg;
    data['zh'] = zh;
    data['kk'] = kk;
    data['ru'] = ru;
    data['ps'] = ps;
    data['uk'] = uk;
    data['tr'] = tr;
    data['nl'] = nl;
    data['ml'] = ml;
    data['mr'] = mr;
    data['fr'] = fr;
    data['ku'] = ku;
    data['en'] = en;
    data['hi'] = hi;
    data['ce'] = ce;
    data['ta'] = ta;
    data['el'] = el;
    data['es'] = es;
    data['de'] = de;
    data['ne'] = ne;
    data['hu'] = hu;
    data['it'] = it;
    data['ko'] = ko;
    data['he'] = he;
    data['ug'] = ug;
    data['kn'] = kn;
    data['ka'] = ka;
    return data;
  }
}
