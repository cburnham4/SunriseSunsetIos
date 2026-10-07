"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { toPng } from "html-to-image";
import { SS } from "./sunrise-colors";

const DESIGN_W = 1320;
const DESIGN_H = 2868;

const IPHONE_SIZES = [
  { label: '6.9"', w: 1320, h: 2868 },
  { label: '6.5"', w: 1284, h: 2778 },
  { label: '6.3"', w: 1206, h: 2622 },
  { label: '6.1"', w: 1125, h: 2436 },
] as const;

const MK_W = 1022;
const MK_H = 2082;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

const PHONE_W = 900;

const CREATIVE_W = 1311;
const CREATIVE_H = 737;

const IMAGE_PATHS = [
  "/mockup.png",
  "/app-icon.png",
  "/screenshots/home.png",
  "/screenshots/sunrise.png",
  "/screenshots/dawn.png",
  "/screenshots/locations.png",
  "/screenshots/weather.png",
];

function Phone({
  src,
  mockupSrc,
  alt,
  style,
}: {
  src: string;
  mockupSrc: string;
  alt: string;
  style?: React.CSSProperties;
}) {
  return (
    <div style={{ position: "relative", aspectRatio: `${MK_W}/${MK_H}`, ...style }}>
      <img src={mockupSrc} alt="" style={{ display: "block", width: "100%", height: "100%" }} draggable={false} />
      <div
        style={{
          position: "absolute",
          left: `${SC_L}%`,
          top: `${SC_T}%`,
          width: `${SC_W}%`,
          height: `${SC_H}%`,
          borderRadius: `${SC_RX}% / ${SC_RY}%`,
          overflow: "hidden",
        }}
      >
        <img
          src={src}
          alt={alt}
          style={{ display: "block", width: "100%", height: "100%", objectFit: "cover", objectPosition: "top" }}
          draggable={false}
        />
      </div>
    </div>
  );
}

function Label({ children, color = SS.accent }: { children: React.ReactNode; color?: string }) {
  return (
    <p
      style={{
        fontSize: DESIGN_W * 0.026,
        fontWeight: 700,
        letterSpacing: "0.16em",
        textTransform: "uppercase" as const,
        color,
        marginBottom: DESIGN_W * 0.022,
        lineHeight: 1,
      }}
    >
      {children}
    </p>
  );
}

function Headline({ children, color = SS.ink }: { children: React.ReactNode; color?: string }) {
  return (
    <h1
      style={{
        fontSize: DESIGN_W * 0.1,
        fontWeight: 800,
        lineHeight: 0.95,
        color,
        letterSpacing: "-0.03em",
        margin: 0,
      }}
    >
      {children}
    </h1>
  );
}

function Sub({ children, color = SS.muted }: { children: React.ReactNode; color?: string }) {
  return (
    <p
      style={{
        fontSize: DESIGN_W * 0.038,
        lineHeight: 1.35,
        color,
        marginTop: DESIGN_W * 0.028,
        maxWidth: "85%",
      }}
    >
      {children}
    </p>
  );
}

function Slide({
  bg,
  children,
  fontFamily,
  w = DESIGN_W,
  h = DESIGN_H,
}: {
  bg: string;
  children: React.ReactNode;
  fontFamily?: string;
  w?: number;
  h?: number;
}) {
  return (
    <div
      style={{
        width: w,
        height: h,
        background: bg,
        position: "relative",
        overflow: "hidden",
        fontFamily: fontFamily ?? "var(--font-geist-sans), ui-rounded, system-ui, -apple-system, sans-serif",
      }}
    >
      {children}
    </div>
  );
}

function Blob({
  x,
  y,
  size,
  color,
  opacity = 0.18,
}: {
  x: number;
  y: number;
  size: number;
  color: string;
  opacity?: number;
}) {
  return (
    <div
      style={{
        position: "absolute",
        left: x - size / 2,
        top: y - size / 2,
        width: size,
        height: size,
        borderRadius: "50%",
        background: color,
        opacity,
        filter: `blur(${size * 0.3}px)`,
        pointerEvents: "none",
      }}
    />
  );
}

type ImgFn = (path: string) => string;

type SlideConfig = {
  id: string;
  title: string;
  canvasW?: number;
  canvasH?: number;
  exportW?: number;
  exportH?: number;
  render: (img: ImgFn) => React.ReactNode;
};

const slides: SlideConfig[] = [
  {
    id: "01-hero",
    title: "Hero",
    render: (img) => (
      <Slide bg={`linear-gradient(160deg, ${SS.greenDeep} 0%, ${SS.greenDark} 45%, ${SS.green} 100%)`}>
        <Blob x={DESIGN_W * 1.0} y={DESIGN_H * 0.18} size={900} color={SS.greenGlow} opacity={0.28} />
        <Blob x={DESIGN_W * -0.1} y={DESIGN_H * 0.55} size={600} color="#6FB07E" opacity={0.14} />

        <div style={{ position: "absolute", left: DESIGN_W * 0.08, top: DESIGN_H * 0.055, zIndex: 2 }}>
          <div style={{ marginBottom: DESIGN_W * 0.03, display: "flex", alignItems: "center", gap: DESIGN_W * 0.025 }}>
            <img
              src={img("/app-icon.png")}
              alt="Sunrise & Sunset"
              style={{ width: DESIGN_W * 0.13, height: DESIGN_W * 0.13, borderRadius: DESIGN_W * 0.025 }}
            />
            <span style={{ fontSize: DESIGN_W * 0.036, fontWeight: 700, color: "rgba(255,255,255,0.88)", letterSpacing: "0.02em" }}>
              Sunrise & Sunset
            </span>
          </div>
          <Label color="#A7D4B2">Daylight</Label>
          <Headline color="#FFFFFF">
            Know when
            <br />
            the sun rises
          </Headline>
          <Sub color="rgba(255,255,255,0.62)">Exact sunrise, sunset, and twilight times for any place.</Sub>
        </div>

        <div
          style={{
            position: "absolute",
            left: "50%",
            bottom: DESIGN_H * 0.02,
            transform: "translateX(-50%)",
            width: PHONE_W,
            zIndex: 3,
          }}
        >
          <Phone mockupSrc={img("/mockup.png")} src={img("/screenshots/home.png")} alt="Sunrise" />
        </div>
      </Slide>
    ),
  },
  {
    id: "02-next-up",
    title: "Next Up",
    render: (img) => (
      <Slide bg={`linear-gradient(175deg, ${SS.cream} 0%, ${SS.mint} 55%, #DCEBDZ 100%)`.replace("#DCEBDZ", "#DCEBDF")}>
        <Blob x={DESIGN_W * 0.9} y={DESIGN_H * 0.08} size={700} color={SS.greenGlow} opacity={0.12} />

        <div style={{ position: "absolute", left: DESIGN_W * 0.08, top: DESIGN_H * 0.055, zIndex: 2 }}>
          <Label color={SS.accent}>Today</Label>
          <Headline color={SS.ink}>
            Next sunrise
            <br />
            or sunset
          </Headline>
          <Sub>See what&apos;s coming next, plus daylight length at a glance.</Sub>
        </div>

        <div
          style={{
            position: "absolute",
            right: -DESIGN_W * 0.06,
            bottom: DESIGN_H * 0.03,
            width: PHONE_W * 0.95,
            zIndex: 3,
            transform: "rotate(3deg)",
          }}
        >
          <Phone mockupSrc={img("/mockup.png")} src={img("/screenshots/sunrise.png")} alt="Next up" />
        </div>
      </Slide>
    ),
  },
  {
    id: "03-twilight",
    title: "Twilight",
    render: (img) => (
      <Slide bg={`linear-gradient(160deg, #0C1A12 0%, #163224 55%, #1E4030 100%)`}>
        <Blob x={DESIGN_W * 0.8} y={DESIGN_H * 0.12} size={800} color={SS.greenGlow} opacity={0.2} />
        <Blob x={DESIGN_W * 0.1} y={DESIGN_H * 0.6} size={500} color="#2F6B40" opacity={0.14} />

        <div style={{ position: "absolute", left: DESIGN_W * 0.08, top: DESIGN_H * 0.055, zIndex: 2 }}>
          <Label color="#A7D4B2">Dawn & dusk</Label>
          <Headline color="#FFFFFF">
            Civil to
            <br />
            astronomical
          </Headline>
          <Sub color="rgba(255,255,255,0.6)">Twilight times hunters and photographers actually use.</Sub>
        </div>

        <div
          style={{
            position: "absolute",
            left: "50%",
            bottom: DESIGN_H * 0.02,
            transform: "translateX(-50%)",
            width: PHONE_W,
            zIndex: 3,
          }}
        >
          <Phone mockupSrc={img("/mockup.png")} src={img("/screenshots/dawn.png")} alt="Twilight" />
        </div>
      </Slide>
    ),
  },
  {
    id: "04-locations",
    title: "Locations",
    render: (img) => (
      <Slide bg={`linear-gradient(170deg, #F8FBF8 0%, #EEF6F0 100%)`}>
        <Blob x={DESIGN_W * 0.15} y={DESIGN_H * 0.08} size={600} color={SS.greenGlow} opacity={0.1} />

        <div style={{ position: "absolute", left: DESIGN_W * 0.08, top: DESIGN_H * 0.055, zIndex: 2 }}>
          <Label color={SS.muted}>Places</Label>
          <Headline color={SS.ink}>
            Switch cities
            <br />
            in a tap
          </Headline>
          <Sub>Save spots you care about and jump between them instantly.</Sub>
        </div>

        <div
          style={{
            position: "absolute",
            left: -DESIGN_W * 0.06,
            bottom: DESIGN_H * 0.03,
            width: PHONE_W * 0.95,
            zIndex: 3,
            transform: "rotate(-3deg)",
          }}
        >
          <Phone mockupSrc={img("/mockup.png")} src={img("/screenshots/locations.png")} alt="Locations" />
        </div>
      </Slide>
    ),
  },
  {
    id: "05-weather",
    title: "Weather",
    render: (img) => (
      <Slide bg={`linear-gradient(165deg, #10241A 0%, #1A3826 50%, #244A32 100%)`}>
        <Blob x={DESIGN_W * 1.0} y={DESIGN_H * 0.15} size={900} color="#7BC48A" opacity={0.16} />
        <Blob x={DESIGN_W * 0.0} y={DESIGN_H * 0.65} size={500} color={SS.greenGlow} opacity={0.12} />

        <div style={{ position: "absolute", left: DESIGN_W * 0.08, top: DESIGN_H * 0.055, zIndex: 2 }}>
          <Label color="#A7D4B2">Forecast</Label>
          <Headline color="#FFFFFF">
            Weather for
            <br />
            the same spot
          </Headline>
          <Sub color="rgba(255,255,255,0.6)">Hourly and weekly outlook right beside your sun times.</Sub>
        </div>

        <div
          style={{
            position: "absolute",
            left: "50%",
            bottom: DESIGN_H * 0.02,
            transform: "translateX(-50%)",
            width: PHONE_W,
            zIndex: 3,
          }}
        >
          <Phone mockupSrc={img("/mockup.png")} src={img("/screenshots/weather.png")} alt="Weather" />
        </div>
      </Slide>
    ),
  },
  {
    id: "06-universal-creative",
    title: "Universal Creative (Header + Search)",
    canvasW: CREATIVE_W,
    canvasH: CREATIVE_H,
    exportW: 5244,
    exportH: 2950,
    render: (img) => {
      const CW = CREATIVE_W;
      const CH = CREATIVE_H;
      const PHONE_CW = 298;
      return (
        <Slide bg={`linear-gradient(130deg, ${SS.greenDeep} 0%, ${SS.greenDark} 45%, ${SS.green} 100%)`} w={CW} h={CH}>
          <Blob x={CW * 0.88} y={CH * 0.25} size={560} color={SS.greenGlow} opacity={0.24} />
          <Blob x={CW * 0.65} y={CH * 0.85} size={320} color="#6FB07E" opacity={0.14} />

          <div style={{ position: "absolute", left: CW * 0.05, top: CH * 0.1, width: CW * 0.52, zIndex: 2 }}>
            <div style={{ display: "flex", alignItems: "center", gap: CW * 0.018, marginBottom: CH * 0.07 }}>
              <img
                src={img("/app-icon.png")}
                alt="Sunrise & Sunset"
                style={{ width: CH * 0.14, height: CH * 0.14, borderRadius: CH * 0.028 }}
              />
              <span style={{ fontSize: CH * 0.07, fontWeight: 700, color: "rgba(255,255,255,0.9)" }}>
                Sunrise & Sunset
              </span>
            </div>

            <h2
              style={{
                fontSize: CH * 0.148,
                fontWeight: 800,
                lineHeight: 0.92,
                color: "#FFFFFF",
                letterSpacing: "-0.03em",
                margin: 0,
                marginBottom: CH * 0.055,
              }}
            >
              Know when
              <br />
              the sun rises
            </h2>

            <p
              style={{
                fontSize: CH * 0.066,
                lineHeight: 1.38,
                color: "rgba(255,255,255,0.62)",
                margin: 0,
                maxWidth: "90%",
              }}
            >
              Sunrise, sunset, twilight, and weather
              <br />
              for any place you care about.
            </p>
          </div>

          <div
            style={{
              position: "absolute",
              right: CW * 0.025,
              top: (CH - PHONE_CW * (MK_H / MK_W)) / 2 - CH * 0.02,
              width: PHONE_CW,
              zIndex: 3,
              transform: "rotate(2.5deg)",
              filter: "drop-shadow(0 24px 48px rgba(0,0,0,0.55))",
            }}
          >
            <Phone mockupSrc={img("/mockup.png")} src={img("/screenshots/home.png")} alt="Sunrise screen" />
          </div>
        </Slide>
      );
    },
  },
];

async function preload(paths: string[]): Promise<Record<string, string>> {
  const cache: Record<string, string> = {};
  await Promise.all(
    paths.map(async (path) => {
      try {
        const resp = await fetch(path);
        if (!resp.ok) return;
        const blob = await resp.blob();
        cache[path] = await new Promise<string>((resolve, reject) => {
          const r = new FileReader();
          r.onloadend = () => resolve(r.result as string);
          r.onerror = reject;
          r.readAsDataURL(blob);
        });
      } catch {
        /* skip */
      }
    }),
  );
  return cache;
}

function downloadDataUrl(dataUrl: string, name: string) {
  const a = document.createElement("a");
  a.href = dataUrl;
  a.download = name;
  a.click();
}

const PREVIEW_W = 280;

export default function ScreenshotsPage() {
  const [cache, setCache] = useState<Record<string, string>>({});
  const [ready, setReady] = useState(false);
  const [sizeIdx, setSizeIdx] = useState(0);
  const [exporting, setExporting] = useState(false);
  const slideRefs = useRef<(HTMLDivElement | null)[]>([]);

  const img = useCallback((path: string) => cache[path] ?? path, [cache]);

  useEffect(() => {
    preload(IMAGE_PATHS).then((c) => {
      setCache(c);
      setReady(true);
    });
  }, []);

  const captureSlide = useCallback(
    async (index: number) => {
      const el = slideRefs.current[index];
      if (!el) return null;
      const slide = slides[index];
      const canvasW = slide.canvasW ?? DESIGN_W;
      const canvasH = slide.canvasH ?? DESIGN_H;
      const tw = slide.exportW ?? IPHONE_SIZES[sizeIdx].w;
      const th = slide.exportH ?? IPHONE_SIZES[sizeIdx].h;

      const prev = el.style.cssText;
      el.style.cssText = `
      position: fixed !important;
      left: 0 !important;
      top: 0 !important;
      z-index: 2147483647 !important;
      transform: none !important;
      width: ${canvasW}px !important;
      height: ${canvasH}px !important;
    `;
      await new Promise((r) => setTimeout(r, 80));
      await toPng(el, { width: canvasW, height: canvasH, pixelRatio: 1, cacheBust: true });
      await new Promise((r) => setTimeout(r, 120));
      let dataUrl = await toPng(el, { width: canvasW, height: canvasH, pixelRatio: 1, cacheBust: true });
      el.style.cssText = prev;

      if (tw !== canvasW || th !== canvasH) {
        const image = new window.Image();
        image.src = dataUrl;
        await new Promise((res, rej) => {
          image.onload = res;
          image.onerror = rej;
        });
        const canvas = document.createElement("canvas");
        canvas.width = tw;
        canvas.height = th;
        canvas.getContext("2d")!.drawImage(image, 0, 0, tw, th);
        dataUrl = canvas.toDataURL("image/png");
      }

      return { filename: `${slide.id}-sunrise-${tw}x${th}.png`, dataUrl };
    },
    [sizeIdx],
  );

  useEffect(() => {
    if (!ready) return;
    const w = window as unknown as Record<string, unknown>;
    w.__SUNRISE_EXPORT_SLIDE__ = (i: number) => captureSlide(i);
    w.__SUNRISE_EXPORT_ALL__ = async () => {
      const out = [];
      for (let i = 0; i < slides.length; i++) {
        const r = await captureSlide(i);
        if (r) out.push(r);
        await new Promise((res) => setTimeout(res, 200));
      }
      return out;
    };
    return () => {
      delete w.__SUNRISE_EXPORT_SLIDE__;
      delete w.__SUNRISE_EXPORT_ALL__;
    };
  }, [ready, captureSlide]);

  const exportSlide = async (i: number) => {
    setExporting(true);
    try {
      const r = await captureSlide(i);
      if (r) downloadDataUrl(r.dataUrl, r.filename);
    } finally {
      setExporting(false);
    }
  };

  const exportAll = async () => {
    setExporting(true);
    try {
      for (let i = 0; i < slides.length; i++) {
        const r = await captureSlide(i);
        if (r) downloadDataUrl(r.dataUrl, r.filename);
        await new Promise((res) => setTimeout(res, 350));
      }
    } finally {
      setExporting(false);
    }
  };

  if (!ready) {
    return <div className="flex min-h-screen items-center justify-center text-zinc-600">Loading assets…</div>;
  }

  return (
    <div className="min-h-screen pb-24 font-sans">
      <header className="sticky top-0 z-50 border-b border-zinc-200 bg-white/95 px-6 py-4 backdrop-blur">
        <div className="mx-auto flex max-w-6xl flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-lg font-semibold">Sunrise & Sunset — App Store screenshots</h1>
            <p className="text-sm text-zinc-500">
              Fresh simulator captures in <code className="rounded bg-zinc-100 px-1">public/screenshots/</code>
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <label className="text-sm text-zinc-600">
              Size
              <select
                className="ml-2 rounded-lg border border-zinc-300 bg-white px-2 py-1.5 text-sm"
                value={sizeIdx}
                onChange={(e) => setSizeIdx(Number(e.target.value))}
              >
                {IPHONE_SIZES.map((s, i) => (
                  <option key={s.label} value={i}>
                    {s.label} ({s.w}×{s.h})
                  </option>
                ))}
              </select>
            </label>
            <button
              type="button"
              disabled={exporting}
              onClick={exportAll}
              className="rounded-lg bg-black px-4 py-2 text-sm font-medium text-white disabled:opacity-50"
            >
              {exporting ? "Exporting…" : "Export all PNGs"}
            </button>
          </div>
        </div>
      </header>

      <div className="mx-auto grid max-w-6xl gap-6 px-4 py-8 sm:grid-cols-2 lg:grid-cols-3">
        {slides.map((slide, i) => {
          const canvasW = slide.canvasW ?? DESIGN_W;
          const canvasH = slide.canvasH ?? DESIGN_H;
          const previewH = (PREVIEW_W * canvasH) / canvasW;
          return (
            <div key={slide.id} className="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-sm">
              <div className="flex items-center justify-between border-b border-zinc-100 px-4 py-2">
                <span className="text-sm font-medium text-zinc-700">{slide.title}</span>
                <button
                  type="button"
                  disabled={exporting}
                  onClick={() => exportSlide(i)}
                  className="rounded-lg bg-zinc-900 px-3 py-1.5 text-xs font-medium text-white disabled:opacity-50"
                >
                  Export
                </button>
              </div>
              <div className="flex justify-center overflow-hidden bg-zinc-100 p-3">
                <div style={{ width: PREVIEW_W, height: previewH, overflow: "hidden", position: "relative" }}>
                  <div
                    style={{
                      width: canvasW,
                      height: canvasH,
                      transform: `scale(${PREVIEW_W / canvasW})`,
                      transformOrigin: "top left",
                    }}
                  >
                    <div
                      ref={(el) => {
                        slideRefs.current[i] = el;
                      }}
                    >
                      {slide.render(img)}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
