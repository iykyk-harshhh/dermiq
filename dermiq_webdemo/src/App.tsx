import { useEffect, useState } from "react";
import {
  Home as HomeIcon,
  CalendarDays,
  ScanLine,
  ShoppingBag,
  Sparkles,
  Sun,
  Moon,
  Check,
  ChevronRight,
  Star,
  ArrowLeft,
  Camera,
  Droplet,
  Flame,
  TrendingUp,
} from "lucide-react";

/* ── Brand ─────────────────────────────────────────────────────────────── */
const PRIMARY = "#6C4BFF";
const DEEP = "#2F216F";
const heroGradient = "linear-gradient(135deg,#1E1B4B 0%,#3B2D9F 45%,#5E3FFF 100%)";
const ctaGradient = "linear-gradient(135deg,#6C4BFF 0%,#B084FF 100%)";

/* ── Product data (real market products) ───────────────────────────────── */
type Product = {
  id: string;
  name: string;
  brand: string;
  sub: string;
  price: number;
  mrp: number;
  rating: number;
  match: number;
  accent: string;
};
const PRODUCTS: Product[] = [
  { id: "p1", name: "Hydrating Facial Cleanser", brand: "CeraVe", sub: "Cleanser", price: 599, mrp: 799, rating: 4.8, match: 94, accent: "#06B6D4" },
  { id: "p2", name: "Niacinamide 10% + Zinc 1%", brand: "The Ordinary", sub: "Serum", price: 599, mrp: 799, rating: 4.6, match: 92, accent: "#7C5CFF" },
  { id: "p3", name: "Anthelios UVMune 400 SPF 50+", brand: "La Roche-Posay", sub: "Sunscreen", price: 1299, mrp: 1599, rating: 4.9, match: 97, accent: "#F59E0B" },
  { id: "p4", name: "Vitamin C 10% Face Serum", brand: "Minimalist", sub: "Serum", price: 599, mrp: 699, rating: 4.4, match: 90, accent: "#F97316" },
  { id: "p5", name: "Moisturizing Cream", brand: "Cetaphil", sub: "Moisturizer", price: 449, mrp: 549, rating: 4.7, match: 90, accent: "#10B981" },
  { id: "p6", name: "Hydro Boost Water Gel", brand: "Neutrogena", sub: "Moisturizer", price: 899, mrp: 1150, rating: 4.6, match: 89, accent: "#38BDF8" },
  { id: "p7", name: "Onion Hair Fall Shampoo", brand: "Mamaearth", sub: "Shampoo", price: 399, mrp: 499, rating: 4.3, match: 88, accent: "#D97706" },
  { id: "p8", name: "2% BHA Liquid Exfoliant", brand: "Paula's Choice", sub: "Exfoliator", price: 2300, mrp: 2700, rating: 4.7, match: 93, accent: "#EF4444" },
];

/* ── Open Beauty Facts image lookup (real photos, cached) ──────────────── */
const imgCache = new Map<string, string | null>();
function useProductImage(brand: string, name: string) {
  const key = `${brand} ${name}`;
  const [url, setUrl] = useState<string | null | undefined>(imgCache.get(key));
  useEffect(() => {
    if (imgCache.has(key)) {
      setUrl(imgCache.get(key)!);
      return;
    }
    let alive = true;
    const u =
      "https://world.openbeautyfacts.org/cgi/search.pl?search_terms=" +
      encodeURIComponent(key) +
      "&search_simple=1&action=process&json=1&page_size=1&fields=image_front_url,image_url";
    fetch(u)
      .then((r) => r.json())
      .then((j) => {
        const p = j?.products?.[0];
        const found: string | null = p?.image_front_url || p?.image_url || null;
        imgCache.set(key, found);
        if (alive) setUrl(found);
      })
      .catch(() => {
        imgCache.set(key, null);
        if (alive) setUrl(null);
      });
    return () => {
      alive = false;
    };
  }, [key]);
  return url; // undefined=loading, null=none, string=url
}

function ProductImg({ p, className = "" }: { p: Product; className?: string }) {
  const url = useProductImage(p.brand, p.name);
  if (typeof url === "string") {
    return (
      <div className={`flex items-center justify-center bg-white ${className}`}>
        <img src={url} alt={p.name} className="h-full w-full object-contain p-2" />
      </div>
    );
  }
  return (
    <div
      className={`flex items-center justify-center ${className}`}
      style={{ background: `linear-gradient(135deg,${p.accent}26,${p.accent}59)` }}
    >
      <div
        className="flex h-12 w-12 items-center justify-center rounded-full bg-white text-lg font-bold shadow"
        style={{ color: p.accent }}
      >
        {p.brand[0]}
      </div>
    </div>
  );
}

/* ── Shared chrome ─────────────────────────────────────────────────────── */
function StatusBar() {
  return (
    <div className="flex items-center justify-between px-5 pt-3 text-[11px] font-semibold text-slate-700">
      <span>9:41</span>
      <span style={{ color: DEEP, fontWeight: 800 }}>
        derm<span style={{ color: PRIMARY }}>i</span>q
      </span>
      <span>📶 🔋</span>
    </div>
  );
}

function Section({ title, action }: { title: string; action?: string }) {
  return (
    <div className="mb-3 flex items-center justify-between">
      <h3 className="text-[15px] font-bold text-slate-900">{title}</h3>
      {action && (
        <span className="flex items-center text-xs font-semibold" style={{ color: PRIMARY }}>
          {action} <ChevronRight size={14} />
        </span>
      )}
    </div>
  );
}

function Ring({ value }: { value: number }) {
  const r = 38;
  const c = 2 * Math.PI * r;
  const off = c * (1 - value / 100);
  return (
    <svg width="96" height="96" className="-rotate-90">
      <circle cx="48" cy="48" r={r} stroke="rgba(255,255,255,.15)" strokeWidth="8" fill="none" />
      <circle cx="48" cy="48" r={r} stroke="white" strokeWidth="8" fill="none" strokeLinecap="round" strokeDasharray={c} strokeDashoffset={off} />
      <text x="48" y="52" textAnchor="middle" transform="rotate(90 48 48)" fill="white" fontSize="18" fontWeight="700">{value}%</text>
    </svg>
  );
}

/* ── HOME ──────────────────────────────────────────────────────────────── */
function Home({ go }: { go: (t: Tab) => void }) {
  const score = 82;
  return (
    <div className="space-y-5 px-4 pb-28 pt-2">
      <div>
        <h2 className="text-2xl font-extrabold text-slate-900">Good Morning, Harshith ✨</h2>
        <p className="text-sm text-slate-500">Let's check in on your skin today.</p>
      </div>

      <div className="overflow-hidden rounded-3xl p-5 text-white shadow-xl" style={{ background: heroGradient }}>
        <div className="flex items-center justify-between">
          <span className="text-sm text-white/70">DermIQ Health Score</span>
          <span className="rounded-full border border-white/20 bg-white/10 px-2.5 py-1 text-[10px] uppercase tracking-wide">Updated today</span>
        </div>
        <div className="mt-4 flex items-center justify-between">
          <div>
            <div className="flex items-end gap-1">
              <span className="text-5xl font-extrabold leading-none">{score}</span>
              <span className="mb-1 text-white/50">/100</span>
            </div>
            <div className="mt-2 flex items-center gap-2 text-xs">
              <span className="h-2 w-2 rounded-full bg-emerald-400" />
              <span className="font-bold text-emerald-400">Excellent</span>
              <TrendingUp size={13} className="text-emerald-400" />
              <span className="text-white/60">+5 pts</span>
            </div>
          </div>
          <Ring value={score} />
        </div>
        <div className="my-4 h-px bg-white/15" />
        <div className="grid grid-cols-3 text-center text-xs">
          {[
            ["Hydration", "72%", <Droplet key="d" size={14} />],
            ["Oil Balance", "65%", <Sparkles key="s" size={14} />],
            ["UV Shield", "88%", <Sun key="u" size={14} />],
          ].map((m) => (
            <div key={m[0] as string} className="flex flex-col items-center gap-1">
              <span className="text-white/70">{m[2]}</span>
              <span className="font-bold">{m[1] as string}</span>
              <span className="text-white/50">{m[0] as string}</span>
            </div>
          ))}
        </div>
        <button onClick={() => go("scan")} className="mt-4 w-full rounded-xl border border-white/20 bg-white/10 py-2.5 text-sm font-bold">
          View Full Analysis →
        </button>
      </div>

      <div>
        <Section title="Top Concerns" />
        <div className="grid grid-cols-3 gap-2.5">
          {[
            ["Spots", "Mild", "#FF8C6B"],
            ["Texture", "Moderate", "#F59E0B"],
            ["Pores", "Mild", "#7B62C4"],
          ].map((c) => (
            <div key={c[0]} className="rounded-2xl bg-white p-3 shadow-sm">
              <span className="flex h-8 w-8 items-center justify-center rounded-full" style={{ background: `${c[2]}26` }}>
                <span className="h-3 w-3 rounded-full" style={{ background: c[2] }} />
              </span>
              <p className="mt-2 text-sm font-bold text-slate-800">{c[0]}</p>
              <p className="text-xs text-slate-400">{c[1]}</p>
            </div>
          ))}
        </div>
      </div>

      <button onClick={() => go("scan")} className="flex w-full items-center gap-4 rounded-2xl p-4 text-left shadow-sm" style={{ background: "linear-gradient(135deg,#F5F3FF,#EDE9FE)", border: "1px solid #6c4bff2e" }}>
        <span className="flex h-12 w-12 items-center justify-center rounded-2xl text-white" style={{ background: ctaGradient }}><Camera size={22} /></span>
        <span className="flex-1">
          <span className="block text-sm font-bold text-slate-900">Analyze Your Skin</span>
          <span className="block text-xs text-slate-500">Scan your face or a product for instant AI analysis</span>
        </span>
        <span className="rounded-xl px-3 py-2 text-xs font-bold text-white" style={{ background: ctaGradient }}>Scan</span>
      </button>

      <button onClick={() => go("shop")} className="flex w-full items-center gap-4 rounded-2xl p-4 text-left shadow-sm" style={{ background: "linear-gradient(135deg,#F0FFFE,#CCFBF1)", border: "1px solid #10b9813a" }}>
        <span className="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-500 text-white"><ShoppingBag size={22} /></span>
        <span className="flex-1">
          <span className="block text-sm font-bold text-slate-900">Shop Skincare</span>
          <span className="block text-xs text-slate-500">88 products matched to your skin & hair profile</span>
        </span>
        <span className="rounded-xl bg-emerald-500 px-3 py-2 text-xs font-bold text-white">Shop</span>
      </button>
    </div>
  );
}

/* ── SCAN ──────────────────────────────────────────────────────────────── */
function Scan() {
  const [scanned, setScanned] = useState<Product | null>(null);
  return (
    <div className="px-4 pb-28 pt-2">
      <h2 className="mb-1 text-xl font-extrabold text-slate-900">Smart Scanner</h2>
      <p className="mb-4 text-sm text-slate-500">Scan a barcode or ingredient label.</p>
      <div className="relative flex h-72 items-center justify-center overflow-hidden rounded-3xl" style={{ background: heroGradient }}>
        <div className="h-44 w-44 rounded-2xl border-2 border-white/70" />
        <div className="absolute left-1/2 top-1/2 h-0.5 w-44 -translate-x-1/2 animate-pulse bg-emerald-400" />
        <span className="absolute bottom-4 text-xs text-white/70">Align the barcode within the frame</span>
      </div>
      <button onClick={() => setScanned(PRODUCTS[0])} className="mt-4 w-full rounded-2xl py-3.5 text-sm font-bold text-white shadow-lg" style={{ background: ctaGradient }}>
        <ScanLine className="mr-2 inline" size={18} /> Simulate Scan
      </button>

      {scanned && (
        <div className="mt-5 rounded-2xl bg-white p-4 shadow-md">
          <div className="flex gap-3">
            <ProductImg p={scanned} className="h-20 w-20 shrink-0 rounded-xl" />
            <div className="min-w-0 flex-1">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-slate-400">{scanned.brand}</p>
              <p className="truncate text-sm font-bold text-slate-900">{scanned.name}</p>
              <span className="mt-1 inline-flex items-center gap-1 rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-bold text-emerald-600">
                <Check size={12} /> {scanned.match}% match for your skin
              </span>
            </div>
          </div>
          <div className="mt-3 flex flex-wrap gap-1.5">
            {["Niacinamide", "Hyaluronic Acid", "Ceramides", "Glycerin"].map((i) => (
              <span key={i} className="rounded-md bg-violet-50 px-2 py-1 text-[11px] font-medium text-violet-700">{i}</span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

/* ── ROUTINE ───────────────────────────────────────────────────────────── */
const AM = ["Hydra-Boost Cleanser", "Glycolic Toner 7%", "Niacinamide 10% Serum", "Moisture Surge 72H", "Ultra Defense SPF 50+"];
const PM = ["Cleansing Balm", "Hydra-Boost Cleanser", "Retinol 0.5% Serum", "Barrier Repair Cream"];
function Routine() {
  const [am, setAm] = useState(true);
  const [done, setDone] = useState<Record<string, boolean>>({});
  const steps = am ? AM : PM;
  const completed = steps.filter((s) => done[(am ? "a" : "p") + s]).length;
  return (
    <div className="px-4 pb-28 pt-2">
      <div className="mb-4 flex items-center justify-between rounded-3xl p-5 text-white shadow-xl" style={{ background: heroGradient }}>
        <div>
          <p className="text-xs text-white/60">Skincare Streak</p>
          <p className="mt-1 flex items-center gap-2 text-3xl font-extrabold"><Flame className="text-orange-400" /> 12 <span className="text-sm font-normal text-white/60">days</span></p>
        </div>
        <div className="text-right text-xs">
          <p className="text-white/60">Today</p>
          <p className="mt-1">AM {completed > 0 && am ? "✅" : "⬜"} · PM ⬜</p>
        </div>
      </div>

      <div className="mb-4 grid grid-cols-2 gap-2 rounded-2xl bg-slate-100 p-1">
        {[
          { l: "AM", v: true, Ic: Sun },
          { l: "PM", v: false, Ic: Moon },
        ].map(({ l, v, Ic }) => (
          <button key={l} onClick={() => setAm(v)} className={`flex items-center justify-center gap-2 rounded-xl py-2.5 text-sm font-bold ${am === v ? "bg-white shadow text-slate-900" : "text-slate-400"}`}>
            <Ic size={16} /> {l}
          </button>
        ))}
      </div>

      <div className="mb-3 flex items-center justify-between">
        <span className="text-sm font-bold text-slate-700">{am ? "Morning" : "Evening"} Routine</span>
        <span className="text-xs text-slate-400">{completed}/{steps.length} done</span>
      </div>

      <div className="space-y-2.5">
        {steps.map((s, i) => {
          const k = (am ? "a" : "p") + s;
          const on = !!done[k];
          return (
            <button key={s} onClick={() => setDone((d) => ({ ...d, [k]: !on }))} className="flex w-full items-center gap-3 rounded-2xl bg-white p-3.5 text-left shadow-sm">
              <span className={`flex h-6 w-6 items-center justify-center rounded-full border-2 ${on ? "border-transparent" : "border-slate-300"}`} style={on ? { background: PRIMARY } : {}}>
                {on && <Check size={14} className="text-white" />}
              </span>
              <span className="flex h-9 w-9 items-center justify-center rounded-lg text-xs font-bold" style={{ background: `${PRIMARY}1a`, color: PRIMARY }}>{i + 1}</span>
              <span className={`flex-1 text-sm font-semibold ${on ? "text-slate-400 line-through" : "text-slate-800"}`}>{s}</span>
            </button>
          );
        })}
      </div>

      <div className="mt-4 flex items-center gap-3 rounded-2xl bg-white p-4 shadow-sm">
        <span className="flex h-11 w-11 items-center justify-center rounded-xl text-white" style={{ background: ctaGradient }}><ShoppingBag size={20} /></span>
        <div className="flex-1">
          <p className="text-sm font-bold text-slate-900">My Shelf</p>
          <p className="text-xs text-slate-500">Track your products & expiry</p>
        </div>
        <ChevronRight className="text-slate-300" />
      </div>
    </div>
  );
}

/* ── SHOP ──────────────────────────────────────────────────────────────── */
function Shop({ onOpen }: { onOpen: (p: Product) => void }) {
  const [tab, setTab] = useState<"Skincare" | "Haircare">("Skincare");
  const list = PRODUCTS.filter((p) => (tab === "Haircare" ? p.sub === "Shampoo" : p.sub !== "Shampoo"));
  return (
    <div className="px-4 pb-28 pt-2">
      <h2 className="mb-3 text-xl font-extrabold text-slate-900">Shop</h2>
      <div className="mb-4 flex gap-2">
        {(["Skincare", "Haircare"] as const).map((t) => (
          <button key={t} onClick={() => setTab(t)} className={`rounded-full px-4 py-1.5 text-sm font-semibold ${tab === t ? "text-white" : "bg-slate-100 text-slate-500"}`} style={tab === t ? { background: PRIMARY } : {}}>{t}</button>
        ))}
      </div>
      <div className="grid grid-cols-2 gap-3">
        {list.map((p) => (
          <button key={p.id} onClick={() => onOpen(p)} className="overflow-hidden rounded-2xl bg-white text-left shadow-sm">
            <ProductImg p={p} className="h-32 w-full" />
            <div className="p-3">
              <p className="text-[10px] font-semibold uppercase tracking-wide text-slate-400">{p.brand}</p>
              <p className="line-clamp-2 text-xs font-bold text-slate-800">{p.name}</p>
              <p className="mt-1 flex items-center gap-1 text-[10px] font-semibold" style={{ color: PRIMARY }}><Sparkles size={11} /> {p.match}% match</p>
              <div className="mt-1.5 flex items-center gap-1.5">
                <span className="text-sm font-extrabold text-slate-900">₹{p.price}</span>
                <span className="text-[11px] text-slate-400 line-through">₹{p.mrp}</span>
              </div>
              <p className="mt-0.5 flex items-center gap-1 text-[11px] text-amber-500"><Star size={11} className="fill-amber-400" /> {p.rating}</p>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function ProductSheet({ p, onClose }: { p: Product; onClose: () => void }) {
  return (
    <div className="absolute inset-0 z-30 flex flex-col bg-white">
      <div className="relative flex h-72 items-center justify-center" style={{ background: `linear-gradient(135deg,${p.accent},${p.accent}bf)` }}>
        <button onClick={onClose} className="absolute left-4 top-4 flex h-9 w-9 items-center justify-center rounded-full bg-white/25 text-white"><ArrowLeft size={18} /></button>
        <div className="h-40 w-40 overflow-hidden rounded-2xl bg-white shadow-xl">
          <ProductImg p={p} className="h-full w-full" />
        </div>
      </div>
      <div className="flex-1 space-y-3 overflow-y-auto p-5">
        <p className="text-xs font-semibold uppercase tracking-wide text-slate-400">{p.brand}</p>
        <h2 className="text-lg font-extrabold text-slate-900">{p.name}</h2>
        <div className="flex items-center gap-3">
          <span className="text-2xl font-extrabold" style={{ color: DEEP }}>₹{p.price}</span>
          <span className="text-sm text-slate-400 line-through">₹{p.mrp}</span>
          <span className="flex items-center gap-1 rounded-md bg-amber-50 px-2 py-0.5 text-xs font-bold text-amber-600"><Star size={11} className="fill-amber-400" /> {p.rating}</span>
        </div>
        <span className="inline-flex items-center gap-1 rounded-full bg-violet-50 px-3 py-1 text-xs font-bold" style={{ color: PRIMARY }}><Sparkles size={12} /> {p.match}% DermIQ match</span>
        <p className="text-sm leading-relaxed text-slate-600">A dermatologist-loved {p.sub.toLowerCase()} from {p.brand}, matched to your skin profile for visible results with consistent use.</p>
      </div>
      <div className="flex gap-3 border-t border-slate-100 p-4">
        <button className="flex-1 rounded-xl border-2 py-3 text-sm font-bold" style={{ borderColor: PRIMARY, color: PRIMARY }}>Add to Cart</button>
        <button className="flex-1 rounded-xl py-3 text-sm font-bold text-white" style={{ background: ctaGradient }}>Buy Now</button>
      </div>
    </div>
  );
}

/* ── CALENDAR (WHOOP-style) ────────────────────────────────────────────── */
function Calendar() {
  const days = [3, 1, 1, 2, 1, 1, 3, 1, 1, 1, 2, 1, 3, 1, 1, 2, 1, 1, 1, 2, 1, 3, 1, 1, 1, 2, 1, 1, 0, 0];
  const color = (v: number) => (v === 1 ? "#22C55E33" : v === 2 ? "#F59E0B33" : v === 3 ? "#EF444426" : "transparent");
  const dot = (v: number) => (v === 1 ? "#22C55E" : v === 2 ? "#F59E0B" : v === 3 ? "#EF4444" : "#CBD5E1");
  return (
    <div className="px-4 pb-28 pt-2">
      <h2 className="mb-4 text-xl font-extrabold text-slate-900">Calendar</h2>
      <div className="mb-4 grid grid-cols-3 gap-2 rounded-3xl p-4 text-center text-white" style={{ background: heroGradient }}>
        {[["🔥", "12", "streak"], ["✓", "78%", "completion"], ["⭐", "19", "perfect"]].map((m) => (
          <div key={m[2]}><div className="text-lg">{m[0]}</div><div className="text-xl font-extrabold">{m[1]}</div><div className="text-[10px] text-white/60">{m[2]}</div></div>
        ))}
      </div>
      <div className="rounded-2xl bg-white p-4 shadow-sm">
        <p className="mb-3 text-center text-sm font-bold text-slate-700">June 2026</p>
        <div className="mb-1 grid grid-cols-7 text-center text-[10px] font-semibold text-slate-400">{["S", "M", "T", "W", "T", "F", "S"].map((d, i) => <span key={i}>{d}</span>)}</div>
        <div className="grid grid-cols-7 gap-1.5">
          {days.map((v, i) => (
            <div key={i} className="flex aspect-square flex-col items-center justify-center rounded-lg text-[11px] text-slate-700" style={{ background: color(v) }}>
              {i + 1}
              <span className="mt-0.5 h-1 w-1 rounded-full" style={{ background: dot(v) }} />
            </div>
          ))}
        </div>
        <div className="mt-3 flex flex-wrap gap-3 text-[11px] text-slate-500">
          <Legend c="#22C55E" l="Full" /><Legend c="#F59E0B" l="Partial" /><Legend c="#EF4444" l="Missed" />
        </div>
      </div>
    </div>
  );
}
function Legend({ c, l }: { c: string; l: string }) {
  return <span className="flex items-center gap-1"><span className="h-3 w-3 rounded" style={{ background: `${c}33` }} />{l}</span>;
}

/* ── Shell ─────────────────────────────────────────────────────────────── */
type Tab = "home" | "routine" | "scan" | "shop" | "calendar";
export default function App() {
  const [tab, setTab] = useState<Tab>("home");
  const [open, setOpen] = useState<Product | null>(null);

  const nav: { t: Tab; l: string; Ic: typeof HomeIcon }[] = [
    { t: "home", l: "Home", Ic: HomeIcon },
    { t: "routine", l: "Routine", Ic: Sun },
    { t: "scan", l: "Scan", Ic: ScanLine },
    { t: "shop", l: "Shop", Ic: ShoppingBag },
    { t: "calendar", l: "Calendar", Ic: CalendarDays },
  ];

  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-5 bg-gradient-to-br from-[#EEE9FF] to-[#F6F3FF] p-6 font-sans">
      <div className="text-center">
        <h1 className="text-2xl font-extrabold" style={{ color: DEEP }}>DermIQ — Interactive Demo</h1>
        <p className="text-sm text-slate-500">Tap around: Home · Scan · Routine · Shop · Calendar. Product photos load live.</p>
      </div>

      <div className="relative h-[760px] w-[380px] overflow-hidden rounded-[40px] border-[10px] border-slate-900 bg-[#F6F3FF] shadow-2xl">
        <StatusBar />
        <div className="h-[670px] overflow-y-auto">
          {tab === "home" && <Home go={setTab} />}
          {tab === "routine" && <Routine />}
          {tab === "scan" && <Scan />}
          {tab === "shop" && <Shop onOpen={setOpen} />}
          {tab === "calendar" && <Calendar />}
        </div>

        {open && <ProductSheet p={open} onClose={() => setOpen(null)} />}

        <div className="absolute bottom-0 left-0 right-0 flex items-center justify-around border-t border-slate-100 bg-white/95 px-2 pb-3 pt-2 backdrop-blur">
          {nav.map(({ t, l, Ic }) =>
            t === "scan" ? (
              <button key={t} onClick={() => setTab(t)} className="-mt-6 flex h-14 w-14 items-center justify-center rounded-full text-white shadow-lg" style={{ background: ctaGradient }}>
                <Ic size={24} />
              </button>
            ) : (
              <button key={t} onClick={() => setTab(t)} className="flex flex-1 flex-col items-center gap-0.5 py-1" style={{ color: tab === t ? PRIMARY : "#94A3B8" }}>
                <Ic size={20} />
                <span className="text-[10px] font-semibold">{l}</span>
              </button>
            )
          )}
        </div>
      </div>
    </div>
  );
}
