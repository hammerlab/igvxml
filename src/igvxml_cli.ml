open Nonstd
module String = Sosa.Native_string

let write_result_to_file result filename =
  let oc = open_out filename in
  let output = Xmlm.make_output ~indent:(Some 4) (`Channel oc) in
  let () = List.iter Igvxml.(Transform.render result)
      ~f:(fun signal -> Xmlm.output output signal) in
  close_out oc

let run run_id genome normal_bam tumor_bam rna_bam vcfs filename
  =
  let result =
    { Igvxml.run_id; genome; normal_bam; tumor_bam; rna_bam; vcfs; } in
  write_result_to_file result filename


let keyval : (Igvxml.desc * Igvxml.url) Cmdliner.Arg.converter =
  let pars s =
    match String.split ~on:(`Character '=') s with
    | k :: v :: [] -> `Ok (k, v)
    | _ -> `Error (sprintf "%s is not a valid key=val" s)
  in
  let prin fmt (k,v) = Format.(pp_print_string fmt (sprintf "%s=%s" k v)) in
  (pars, prin)


let cmd =
  let open Cmdliner in
  let version = "0.0.0" in
  let doc = "Create an IGV session file." in
  let man = [
    `S "Description";
    `P "Create an igv.xml session file from the specified arguments.";
  ] in
  let run_id =
    let doc = "Patient/Run ID." in
    Arg.(required & opt (some string) None & info ["run-id"] ~doc) in
  let genome =
    let doc = "Genome used." in
    Arg.(required & opt (some string) (Some "b37decoy")
         & info ["genome"; "G"] ~doc) in
  let normal_bam =
    let doc = "Path to Normal BAM." in
    Arg.(required & opt (some string) None & info ["normal-bam"; "N"] ~doc) in
  let tumor_bam =
    let doc = "Path to Tumor BAM." in
    Arg.(required & opt (some string) None & info ["tumor-bam"; "T"] ~doc) in
  let rna_bam =
    let doc = "Path to RNA BAM. (optional)" in
    Arg.(value & opt (some string) None  & info ["rna-bam"; "R"] ~doc) in
  let vcfs =
    let doc = "List (comma-separated) of name=path VCFs." in
    Arg.(required & opt (some (list keyval)) None & info ["vcfs"; "V"] ~doc) in
  let output_file =
    let doc = "XML session file to be written." in
    Arg.(required & opt (some string) None & info ["output"; "O"] ~doc) in
  Term.(const run
        $ run_id $ genome $ normal_bam
        $ tumor_bam $ rna_bam $ vcfs $ output_file),
  Term.info "igvxml" ~doc ~version ~man


let () =
  match Cmdliner.Term.eval cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
