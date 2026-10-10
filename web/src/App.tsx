import { useCallback, useEffect, useMemo, useState } from 'react';
import { fetchBook, type BookResult } from './api';
import { parseBibid } from './bookLink';
import { BookCard } from './BookCard';
import { dir, detectLang, t } from './i18n';

type State = { kind: 'loading'; slow: boolean } | BookResult;

export function App() {
  const lang = useMemo(() => detectLang(window.location.search, navigator.language), []);
  const strings = t(lang);
  const bibid = useMemo(() => parseBibid(window.location.pathname), []);

  const [state, setState] = useState<State>({ kind: 'loading', slow: false });
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = dir(lang);
  }, [lang]);

  useEffect(() => {
    if (bibid === null) return;

    const controller = new AbortController();
    setState({ kind: 'loading', slow: false });
    // A sleeping server takes a while; tell the visitor why instead of
    // leaving a spinner that looks stuck.
    const slowTimer = setTimeout(() => setState((s) => (s.kind === 'loading' ? { kind: 'loading', slow: true } : s)), 4000);

    fetchBook(bibid, lang, controller.signal).then((result) => {
      clearTimeout(slowTimer);
      if (!controller.signal.aborted) setState(result);
    });

    return () => {
      clearTimeout(slowTimer);
      controller.abort();
    };
  }, [bibid, lang, attempt]);

  const retry = useCallback(() => setAttempt((n) => n + 1), []);

  return (
    <main className="page">
      <header className="brand">
        <span className="brand__name">{strings.appName}</span>
        <span className="brand__tagline">{strings.tagline}</span>
      </header>

      {bibid === null ? (
        <Message title={strings.notBookTitle} body={strings.notBookBody} />
      ) : state.kind === 'loading' ? (
        <Loading text={state.slow ? strings.waking : strings.loading} />
      ) : state.kind === 'missing' ? (
        <Message title={strings.notFoundTitle} body={strings.notFoundBody} />
      ) : state.kind === 'error' ? (
        <Message title={strings.errorTitle} body={strings.errorBody} action={{ label: strings.retry, onClick: retry }} />
      ) : (
        <BookCard book={state.book} lang={lang} />
      )}
    </main>
  );
}

function Loading({ text }: { text: string }) {
  return (
    <section className="status" role="status" aria-live="polite">
      <div className="spinner" aria-hidden="true" />
      <p>{text}</p>
    </section>
  );
}

function Message({
  title,
  body,
  action,
}: {
  title: string;
  body: string;
  action?: { label: string; onClick: () => void };
}) {
  return (
    <section className="status" role="alert">
      <h1>{title}</h1>
      <p>{body}</p>
      {action && (
        <button type="button" className="button button--primary" onClick={action.onClick}>
          {action.label}
        </button>
      )}
    </section>
  );
}
