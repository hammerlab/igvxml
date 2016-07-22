open Nonstd
module String = Sosa.Native_string

type url = string
type desc = string

type pgv_result =
  { run_id: string;
    genome: string;
    normal_bam: url;
    tumor_bam: url;
    rna_bam: url option;
    vcfs: (desc * url) list;
  }

module Transform : sig
  val render : pgv_result -> Xmlm.signal list
end = struct
  type signals = Xmlm.signal list

  type resource =
    { url: url;
      name: string;
      kind: [`Vcf | `Bam];
    }

  let to_resource ~name ~kind url =
    {url; name; kind; }

  type attr = (string * string) * string
  let attr ?(namespace="") name value : attr =
    (namespace, name), value

  type tag = string * string
  let tag ?(namespace="") name : tag =
    (namespace, name)

  type item = signals
  let item ?(attrs:attr list=[]) ?(children:item list=[]) (tag:tag) : item =
    `El_start (tag, attrs) :: (List.concat children) @ [`El_end]

  let document item : signals =
    `Dtd None :: item

  let render_resource {url; name; } : signals =
    item (tag "Resource")
      ~attrs:[attr "path" url; attr "name" name;]

  let render_resources resources : signals =
    item (tag "Resources")
      ~children:(List.map resources ~f:render_resource)

  let pileup_track ~name url =
    item (tag "Track")
      ~attrs:[attr "id" url;
              attr "name" name;
              attr "displayMode" "EXPANDED"]
      ~children:[item (tag "RenderOptions") ~attrs:[
          attr "colorByTag" "";
          attr "colorOption" "UNEXPECTED_PAIR";
          attr "flagUnmappedPairs" "false";
          attr "groupByTag" "";
          attr "maxInsertSize" "1000";
          attr "minInsertSize" "50";
          attr "shadeBasesOption" "QUALITY";
          attr "shadeCenters" "true";
          attr "showAllBases" "false";
          attr "sortByTag" "";]]

  let data_range =
    item (tag "DataRange") ~attrs:[
      attr "baseline" "0.0";
      attr "drawBaseline" "true";
      attr "flipAxis" "false";
      attr "maximum" "122.0";
      attr "minimum" "0.0";
      attr "type" "LINEAR";]

  let coverage_track ~name url =
    item (tag "Track")
      ~attrs:[attr "id" (url ^ "_coverage");
              attr "name" (name ^ " coverage");
              attr "displayMode" "COLLAPSED"]
      ~children:[data_range]

  let render_bam_panel {url; name} : signals =
    item (tag "Panel") ~attrs:[attr "name" name]
      ~children:[coverage_track ~name url;
                 pileup_track ~name url;]

  let render_vcf_track {url; name} : signals =
    item (tag "Track") ~attrs:[
      attr "id" url;
      attr "name" name;
      attr "SQUISHED_ROW_HEIGHT" "4";
      attr "altColor" "0,0,178";
      attr "autoScale" "false";
      attr "clazz" "org.broad.igv.track.FeatureTrack";
      attr "color" "0,0,178";
      attr "colorMode" "GENOTYPE";
      attr "displayMode" "EXPANDED";
      attr "featureVisibilityWindow" "-1";
      attr "fontSize" "10";
      attr "renderer" "BASIC_FEATURE";
      attr "siteColorMode" "ALLELE_FREQUENCY";
      attr "sortable" "false";
      attr "visible" "true";
      attr "windowFunction" "count";]

  let render_vcf_panel vcfs : signals =
    let children = List.map ~f:render_vcf_track vcfs in
    item (tag "Panel") ~attrs:[attr "name" "VCFS"; attr "height" "210"]
      ~children

  let render_session genome children =
    document (item (tag "Session")
                ~attrs:[attr "genome" genome;
                        attr "locus" "All";
                        attr "version" "1";
                        attr "hasGeneTrack" "true";
                        attr "hasSequenceTrack" "true";]
                ~children)

  let render {run_id; genome; normal_bam; tumor_bam; rna_bam; vcfs; }
    : signals =
    let opt_cons o lst = match o with None -> lst | Some v -> v :: lst in
    let normal_bam = to_resource ~name:"normal" ~kind:`Bam normal_bam in
    let tumor_bam = to_resource ~name:"tumor" ~kind:`Bam tumor_bam in
    let rna_bam = Option.map ~f:(to_resource ~name:"RNA" ~kind:`Bam) rna_bam in
    let vcfs = List.map
        ~f:(fun (name, url) -> to_resource ~kind:`Vcf ~name url) vcfs in
    let resources = render_resources (normal_bam :: tumor_bam ::
                                      (opt_cons rna_bam vcfs)) in
    let normal_bam_panel = render_bam_panel normal_bam in
    let tumor_bam_panel = render_bam_panel tumor_bam in
    let rna_bam_panel = Option.map rna_bam ~f:render_bam_panel in
    let vcf_panel = render_vcf_panel vcfs in
    render_session genome
      ([resources;
        vcf_panel;
        normal_bam_panel;
        tumor_bam_panel;]
       @ (opt_cons rna_bam_panel []))
end
