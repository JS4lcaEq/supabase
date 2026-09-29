CREATE TABLE public.edges (
  pid bigint NOT NULL,
  cid bigint NOT NULL,
  CONSTRAINT edges_pkey PRIMARY KEY (pid, cid),
  CONSTRAINT edges_idp_fkey FOREIGN KEY (pid) REFERENCES public.nodes (id) ON DELETE CASCADE,
  CONSTRAINT edges_idc_fkey FOREIGN KEY (cid) REFERENCES public.nodes (id) ON DELETE CASCADE
);

ALTER TABLE public.edges ENABLE ROW LEVEL SECURITY;

CREATE INDEX edges_cid_idx ON public.edges (cid);
