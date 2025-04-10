import { computed } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import { i18n } from "discourse-i18n";
import ComboBoxComponent from "select-kit/components/combo-box";
import {
  pluginApiIdentifiers,
  selectKitOptions,
} from "select-kit/components/select-kit";

@pluginApiIdentifiers("subscribe-country-select")
@selectKitOptions({
  filterable: true,
  allowAny: false,
  translatedNone: i18n(
    "discourse_subscriptions.subscribe.cardholder_address.country"
  ),
})
@classNames("subscribe-address-country-select")
export default class SubscribeCountrySelect extends ComboBoxComponent {
  nameProperty = "name";
  valueProperty = "value";

  @computed
  get content() {
    return [
      ["AF", i18n("discourse_subscriptions.subscribe.countries.AF")],
      ["AX", i18n("discourse_subscriptions.subscribe.countries.AX")],
      ["AL", i18n("discourse_subscriptions.subscribe.countries.AL")],
      ["DZ", i18n("discourse_subscriptions.subscribe.countries.DZ")],
      ["AS", i18n("discourse_subscriptions.subscribe.countries.AS")],
      ["AD", i18n("discourse_subscriptions.subscribe.countries.AD")],
      ["AO", i18n("discourse_subscriptions.subscribe.countries.AO")],
      ["AI", i18n("discourse_subscriptions.subscribe.countries.AI")],
      ["AQ", i18n("discourse_subscriptions.subscribe.countries.AQ")],
      ["AG", i18n("discourse_subscriptions.subscribe.countries.AG")],
      ["AR", i18n("discourse_subscriptions.subscribe.countries.AR")],
      ["AM", i18n("discourse_subscriptions.subscribe.countries.AM")],
      ["AW", i18n("discourse_subscriptions.subscribe.countries.AW")],
      ["AU", i18n("discourse_subscriptions.subscribe.countries.AU")],
      ["AT", i18n("discourse_subscriptions.subscribe.countries.AT")],
      ["AZ", i18n("discourse_subscriptions.subscribe.countries.AZ")],
      ["BS", i18n("discourse_subscriptions.subscribe.countries.BS")],
      ["BH", i18n("discourse_subscriptions.subscribe.countries.BH")],
      ["BD", i18n("discourse_subscriptions.subscribe.countries.BD")],
      ["BB", i18n("discourse_subscriptions.subscribe.countries.BB")],
      ["BY", i18n("discourse_subscriptions.subscribe.countries.BY")],
      ["BE", i18n("discourse_subscriptions.subscribe.countries.BE")],
      ["BZ", i18n("discourse_subscriptions.subscribe.countries.BZ")],
      ["BJ", i18n("discourse_subscriptions.subscribe.countries.BJ")],
      ["BM", i18n("discourse_subscriptions.subscribe.countries.BM")],
      ["BT", i18n("discourse_subscriptions.subscribe.countries.BT")],
      ["BO", i18n("discourse_subscriptions.subscribe.countries.BO")],
      ["BQ", i18n("discourse_subscriptions.subscribe.countries.BQ")],
      ["BA", i18n("discourse_subscriptions.subscribe.countries.BA")],
      ["BW", i18n("discourse_subscriptions.subscribe.countries.BW")],
      ["BV", i18n("discourse_subscriptions.subscribe.countries.BV")],
      ["BR", i18n("discourse_subscriptions.subscribe.countries.BR")],
      ["IO", i18n("discourse_subscriptions.subscribe.countries.IO")],
      ["BN", i18n("discourse_subscriptions.subscribe.countries.BN")],
      ["BG", i18n("discourse_subscriptions.subscribe.countries.BG")],
      ["BF", i18n("discourse_subscriptions.subscribe.countries.BF")],
      ["BI", i18n("discourse_subscriptions.subscribe.countries.BI")],
      ["KH", i18n("discourse_subscriptions.subscribe.countries.KH")],
      ["CM", i18n("discourse_subscriptions.subscribe.countries.CM")],
      ["CA", i18n("discourse_subscriptions.subscribe.countries.CA")],
      ["CV", i18n("discourse_subscriptions.subscribe.countries.CV")],
      ["KY", i18n("discourse_subscriptions.subscribe.countries.KY")],
      ["CF", i18n("discourse_subscriptions.subscribe.countries.CF")],
      ["TD", i18n("discourse_subscriptions.subscribe.countries.TD")],
      ["CL", i18n("discourse_subscriptions.subscribe.countries.CL")],
      ["CN", i18n("discourse_subscriptions.subscribe.countries.CN")],
      ["CX", i18n("discourse_subscriptions.subscribe.countries.CX")],
      ["CC", i18n("discourse_subscriptions.subscribe.countries.CC")],
      ["CO", i18n("discourse_subscriptions.subscribe.countries.CO")],
      ["KM", i18n("discourse_subscriptions.subscribe.countries.KM")],
      ["CG", i18n("discourse_subscriptions.subscribe.countries.CG")],
      ["CD", i18n("discourse_subscriptions.subscribe.countries.CD")],
      ["CK", i18n("discourse_subscriptions.subscribe.countries.CK")],
      ["CR", i18n("discourse_subscriptions.subscribe.countries.CR")],
      ["CI", i18n("discourse_subscriptions.subscribe.countries.CI")],
      ["HR", i18n("discourse_subscriptions.subscribe.countries.HR")],
      ["CU", i18n("discourse_subscriptions.subscribe.countries.CU")],
      ["CW", i18n("discourse_subscriptions.subscribe.countries.CW")],
      ["CY", i18n("discourse_subscriptions.subscribe.countries.CY")],
      ["CZ", i18n("discourse_subscriptions.subscribe.countries.CZ")],
      ["DK", i18n("discourse_subscriptions.subscribe.countries.DK")],
      ["DJ", i18n("discourse_subscriptions.subscribe.countries.DJ")],
      ["DM", i18n("discourse_subscriptions.subscribe.countries.DM")],
      ["DO", i18n("discourse_subscriptions.subscribe.countries.DO")],
      ["EC", i18n("discourse_subscriptions.subscribe.countries.EC")],
      ["EG", i18n("discourse_subscriptions.subscribe.countries.EG")],
      ["SV", i18n("discourse_subscriptions.subscribe.countries.SV")],
      ["GQ", i18n("discourse_subscriptions.subscribe.countries.GQ")],
      ["ER", i18n("discourse_subscriptions.subscribe.countries.ER")],
      ["EE", i18n("discourse_subscriptions.subscribe.countries.EE")],
      ["ET", i18n("discourse_subscriptions.subscribe.countries.ET")],
      ["FK", i18n("discourse_subscriptions.subscribe.countries.FK")],
      ["FO", i18n("discourse_subscriptions.subscribe.countries.FO")],
      ["FJ", i18n("discourse_subscriptions.subscribe.countries.FJ")],
      ["FI", i18n("discourse_subscriptions.subscribe.countries.FI")],
      ["FR", i18n("discourse_subscriptions.subscribe.countries.FR")],
      ["GF", i18n("discourse_subscriptions.subscribe.countries.GF")],
      ["PF", i18n("discourse_subscriptions.subscribe.countries.PF")],
      ["TF", i18n("discourse_subscriptions.subscribe.countries.TF")],
      ["GA", i18n("discourse_subscriptions.subscribe.countries.GA")],
      ["GM", i18n("discourse_subscriptions.subscribe.countries.GM")],
      ["GE", i18n("discourse_subscriptions.subscribe.countries.GE")],
      ["DE", i18n("discourse_subscriptions.subscribe.countries.DE")],
      ["GH", i18n("discourse_subscriptions.subscribe.countries.GH")],
      ["GI", i18n("discourse_subscriptions.subscribe.countries.GI")],
      ["GR", i18n("discourse_subscriptions.subscribe.countries.GR")],
      ["GL", i18n("discourse_subscriptions.subscribe.countries.GL")],
      ["GD", i18n("discourse_subscriptions.subscribe.countries.GD")],
      ["GP", i18n("discourse_subscriptions.subscribe.countries.GP")],
      ["GU", i18n("discourse_subscriptions.subscribe.countries.GU")],
      ["GT", i18n("discourse_subscriptions.subscribe.countries.GT")],
      ["GG", i18n("discourse_subscriptions.subscribe.countries.GG")],
      ["GN", i18n("discourse_subscriptions.subscribe.countries.GN")],
      ["GW", i18n("discourse_subscriptions.subscribe.countries.GW")],
      ["GY", i18n("discourse_subscriptions.subscribe.countries.GY")],
      ["HT", i18n("discourse_subscriptions.subscribe.countries.HT")],
      ["HM", i18n("discourse_subscriptions.subscribe.countries.HM")],
      ["VA", i18n("discourse_subscriptions.subscribe.countries.VA")],
      ["HN", i18n("discourse_subscriptions.subscribe.countries.HN")],
      ["HK", i18n("discourse_subscriptions.subscribe.countries.HK")],
      ["HU", i18n("discourse_subscriptions.subscribe.countries.HU")],
      ["IS", i18n("discourse_subscriptions.subscribe.countries.IS")],
      ["IN", i18n("discourse_subscriptions.subscribe.countries.IN")],
      ["ID", i18n("discourse_subscriptions.subscribe.countries.ID")],
      ["IR", i18n("discourse_subscriptions.subscribe.countries.IR")],
      ["IQ", i18n("discourse_subscriptions.subscribe.countries.IQ")],
      ["IE", i18n("discourse_subscriptions.subscribe.countries.IE")],
      ["IM", i18n("discourse_subscriptions.subscribe.countries.IM")],
      ["IL", i18n("discourse_subscriptions.subscribe.countries.IL")],
      ["IT", i18n("discourse_subscriptions.subscribe.countries.IT")],
      ["JM", i18n("discourse_subscriptions.subscribe.countries.JM")],
      ["JP", i18n("discourse_subscriptions.subscribe.countries.JP")],
      ["JE", i18n("discourse_subscriptions.subscribe.countries.JE")],
      ["JO", i18n("discourse_subscriptions.subscribe.countries.JO")],
      ["KZ", i18n("discourse_subscriptions.subscribe.countries.KZ")],
      ["KE", i18n("discourse_subscriptions.subscribe.countries.KE")],
      ["KI", i18n("discourse_subscriptions.subscribe.countries.KI")],
      ["KP", i18n("discourse_subscriptions.subscribe.countries.KP")],
      ["KR", i18n("discourse_subscriptions.subscribe.countries.KR")],
      ["KW", i18n("discourse_subscriptions.subscribe.countries.KW")],
      ["KG", i18n("discourse_subscriptions.subscribe.countries.KG")],
      ["LA", i18n("discourse_subscriptions.subscribe.countries.LA")],
      ["LV", i18n("discourse_subscriptions.subscribe.countries.LV")],
      ["LB", i18n("discourse_subscriptions.subscribe.countries.LB")],
      ["LS", i18n("discourse_subscriptions.subscribe.countries.LS")],
      ["LR", i18n("discourse_subscriptions.subscribe.countries.LR")],
      ["LY", i18n("discourse_subscriptions.subscribe.countries.LY")],
      ["LI", i18n("discourse_subscriptions.subscribe.countries.LI")],
      ["LT", i18n("discourse_subscriptions.subscribe.countries.LT")],
      ["LU", i18n("discourse_subscriptions.subscribe.countries.LU")],
      ["MO", i18n("discourse_subscriptions.subscribe.countries.MO")],
      ["MK", i18n("discourse_subscriptions.subscribe.countries.MK")],
      ["MG", i18n("discourse_subscriptions.subscribe.countries.MG")],
      ["MW", i18n("discourse_subscriptions.subscribe.countries.MW")],
      ["MY", i18n("discourse_subscriptions.subscribe.countries.MY")],
      ["MV", i18n("discourse_subscriptions.subscribe.countries.MV")],
      ["ML", i18n("discourse_subscriptions.subscribe.countries.ML")],
      ["MT", i18n("discourse_subscriptions.subscribe.countries.MT")],
      ["MH", i18n("discourse_subscriptions.subscribe.countries.MH")],
      ["MQ", i18n("discourse_subscriptions.subscribe.countries.MQ")],
      ["MR", i18n("discourse_subscriptions.subscribe.countries.MR")],
      ["MU", i18n("discourse_subscriptions.subscribe.countries.MU")],
      ["YT", i18n("discourse_subscriptions.subscribe.countries.YT")],
      ["MX", i18n("discourse_subscriptions.subscribe.countries.MX")],
      ["FM", i18n("discourse_subscriptions.subscribe.countries.FM")],
      ["MD", i18n("discourse_subscriptions.subscribe.countries.MD")],
      ["MC", i18n("discourse_subscriptions.subscribe.countries.MC")],
      ["MN", i18n("discourse_subscriptions.subscribe.countries.MN")],
      ["ME", i18n("discourse_subscriptions.subscribe.countries.ME")],
      ["MS", i18n("discourse_subscriptions.subscribe.countries.MS")],
      ["MA", i18n("discourse_subscriptions.subscribe.countries.MA")],
      ["MZ", i18n("discourse_subscriptions.subscribe.countries.MZ")],
      ["MM", i18n("discourse_subscriptions.subscribe.countries.MM")],
      ["NA", i18n("discourse_subscriptions.subscribe.countries.NA")],
      ["NR", i18n("discourse_subscriptions.subscribe.countries.NR")],
      ["NP", i18n("discourse_subscriptions.subscribe.countries.NP")],
      ["NL", i18n("discourse_subscriptions.subscribe.countries.NL")],
      ["NC", i18n("discourse_subscriptions.subscribe.countries.NC")],
      ["NZ", i18n("discourse_subscriptions.subscribe.countries.NZ")],
      ["NI", i18n("discourse_subscriptions.subscribe.countries.NI")],
      ["NE", i18n("discourse_subscriptions.subscribe.countries.NE")],
      ["NG", i18n("discourse_subscriptions.subscribe.countries.NG")],
      ["NU", i18n("discourse_subscriptions.subscribe.countries.NU")],
      ["NF", i18n("discourse_subscriptions.subscribe.countries.NF")],
      ["MP", i18n("discourse_subscriptions.subscribe.countries.MP")],
      ["NO", i18n("discourse_subscriptions.subscribe.countries.NO")],
      ["OM", i18n("discourse_subscriptions.subscribe.countries.OM")],
      ["PK", i18n("discourse_subscriptions.subscribe.countries.PK")],
      ["PW", i18n("discourse_subscriptions.subscribe.countries.PW")],
      ["PS", i18n("discourse_subscriptions.subscribe.countries.PS")],
      ["PA", i18n("discourse_subscriptions.subscribe.countries.PA")],
      ["PG", i18n("discourse_subscriptions.subscribe.countries.PG")],
      ["PY", i18n("discourse_subscriptions.subscribe.countries.PY")],
      ["PE", i18n("discourse_subscriptions.subscribe.countries.PE")],
      ["PH", i18n("discourse_subscriptions.subscribe.countries.PH")],
      ["PN", i18n("discourse_subscriptions.subscribe.countries.PN")],
      ["PL", i18n("discourse_subscriptions.subscribe.countries.PL")],
      ["PT", i18n("discourse_subscriptions.subscribe.countries.PT")],
      ["PR", i18n("discourse_subscriptions.subscribe.countries.PR")],
      ["QA", i18n("discourse_subscriptions.subscribe.countries.QA")],
      ["RE", i18n("discourse_subscriptions.subscribe.countries.RE")],
      ["RO", i18n("discourse_subscriptions.subscribe.countries.RO")],
      ["RU", i18n("discourse_subscriptions.subscribe.countries.RU")],
      ["RW", i18n("discourse_subscriptions.subscribe.countries.RW")],
      ["BL", i18n("discourse_subscriptions.subscribe.countries.BL")],
      ["SH", i18n("discourse_subscriptions.subscribe.countries.SH")],
      ["KN", i18n("discourse_subscriptions.subscribe.countries.KN")],
      ["LC", i18n("discourse_subscriptions.subscribe.countries.LC")],
      ["MF", i18n("discourse_subscriptions.subscribe.countries.MF")],
      ["PM", i18n("discourse_subscriptions.subscribe.countries.PM")],
      ["VC", i18n("discourse_subscriptions.subscribe.countries.VC")],
      ["WS", i18n("discourse_subscriptions.subscribe.countries.WS")],
      ["SM", i18n("discourse_subscriptions.subscribe.countries.SM")],
      ["ST", i18n("discourse_subscriptions.subscribe.countries.ST")],
      ["SA", i18n("discourse_subscriptions.subscribe.countries.SA")],
      ["SN", i18n("discourse_subscriptions.subscribe.countries.SN")],
      ["RS", i18n("discourse_subscriptions.subscribe.countries.RS")],
      ["SC", i18n("discourse_subscriptions.subscribe.countries.SC")],
      ["SL", i18n("discourse_subscriptions.subscribe.countries.SL")],
      ["SG", i18n("discourse_subscriptions.subscribe.countries.SG")],
      ["SX", i18n("discourse_subscriptions.subscribe.countries.SX")],
      ["SK", i18n("discourse_subscriptions.subscribe.countries.SK")],
      ["SI", i18n("discourse_subscriptions.subscribe.countries.SI")],
      ["SB", i18n("discourse_subscriptions.subscribe.countries.SB")],
      ["SO", i18n("discourse_subscriptions.subscribe.countries.SO")],
      ["ZA", i18n("discourse_subscriptions.subscribe.countries.ZA")],
      ["GS", i18n("discourse_subscriptions.subscribe.countries.GS")],
      ["SS", i18n("discourse_subscriptions.subscribe.countries.SS")],
      ["ES", i18n("discourse_subscriptions.subscribe.countries.ES")],
      ["LK", i18n("discourse_subscriptions.subscribe.countries.LK")],
      ["SD", i18n("discourse_subscriptions.subscribe.countries.SD")],
      ["SR", i18n("discourse_subscriptions.subscribe.countries.SR")],
      ["SJ", i18n("discourse_subscriptions.subscribe.countries.SJ")],
      ["SZ", i18n("discourse_subscriptions.subscribe.countries.SZ")],
      ["SE", i18n("discourse_subscriptions.subscribe.countries.SE")],
      ["CH", i18n("discourse_subscriptions.subscribe.countries.CH")],
      ["SY", i18n("discourse_subscriptions.subscribe.countries.SY")],
      ["TW", i18n("discourse_subscriptions.subscribe.countries.TW")],
      ["TJ", i18n("discourse_subscriptions.subscribe.countries.TJ")],
      ["TZ", i18n("discourse_subscriptions.subscribe.countries.TZ")],
      ["TH", i18n("discourse_subscriptions.subscribe.countries.TH")],
      ["TL", i18n("discourse_subscriptions.subscribe.countries.TL")],
      ["TG", i18n("discourse_subscriptions.subscribe.countries.TG")],
      ["TK", i18n("discourse_subscriptions.subscribe.countries.TK")],
      ["TO", i18n("discourse_subscriptions.subscribe.countries.TO")],
      ["TT", i18n("discourse_subscriptions.subscribe.countries.TT")],
      ["TN", i18n("discourse_subscriptions.subscribe.countries.TN")],
      ["TR", i18n("discourse_subscriptions.subscribe.countries.TR")],
      ["TM", i18n("discourse_subscriptions.subscribe.countries.TM")],
      ["TC", i18n("discourse_subscriptions.subscribe.countries.TC")],
      ["TV", i18n("discourse_subscriptions.subscribe.countries.TV")],
      ["UG", i18n("discourse_subscriptions.subscribe.countries.UG")],
      ["UA", i18n("discourse_subscriptions.subscribe.countries.UA")],
      ["AE", i18n("discourse_subscriptions.subscribe.countries.AE")],
      ["GB", i18n("discourse_subscriptions.subscribe.countries.GB")],
      ["US", i18n("discourse_subscriptions.subscribe.countries.US")],
      ["UM", i18n("discourse_subscriptions.subscribe.countries.UM")],
      ["UY", i18n("discourse_subscriptions.subscribe.countries.UY")],
      ["UZ", i18n("discourse_subscriptions.subscribe.countries.UZ")],
      ["VU", i18n("discourse_subscriptions.subscribe.countries.VU")],
      ["VE", i18n("discourse_subscriptions.subscribe.countries.VE")],
      ["VN", i18n("discourse_subscriptions.subscribe.countries.VN")],
      ["VG", i18n("discourse_subscriptions.subscribe.countries.VG")],
      ["VI", i18n("discourse_subscriptions.subscribe.countries.VI")],
      ["WF", i18n("discourse_subscriptions.subscribe.countries.WF")],
      ["EH", i18n("discourse_subscriptions.subscribe.countries.EH")],
      ["YE", i18n("discourse_subscriptions.subscribe.countries.YE")],
      ["ZM", i18n("discourse_subscriptions.subscribe.countries.ZM")],
      ["ZW", i18n("discourse_subscriptions.subscribe.countries.ZW")],
    ].map((arr) => {
      return { value: arr[0], name: arr[1] };
    });
  }
}
