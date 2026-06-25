# Security Patterns Reference

Quick reference of vulnerable patterns, what they look like in code,
and how to fix them. Used by Claude during manual review (Step 4).

---

## Hardcoded secrets

**Bad:**
```python
STRIPE_KEY = "sk_live_abc123xyz"
db_password = "MyP@ssw0rd!"
```

**Good:**
```python
STRIPE_KEY = os.environ["STRIPE_API_KEY"]
db_password = os.environ["DB_PASSWORD"]
```

---

## Shell injection

**Bad:**
```python
os.system(f"convert {user_input} output.png")
subprocess.call(f"grep {query} logs.txt", shell=True)
```

**Good:**
```python
subprocess.run(["convert", user_input, "output.png"], check=True)
subprocess.run(["grep", query, "logs.txt"], check=True)
```

---

## SQL injection

**Bad:**
```python
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
cursor.execute("SELECT * FROM users WHERE name = '" + name + "'")
```

**Good:**
```python
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
cursor.execute("SELECT * FROM users WHERE name = %s", (name,))
```

---

## Error detail leakage

**Bad:**
```python
except Exception as e:
    return {"error": str(e), "trace": traceback.format_exc()}
```

**Good:**
```python
except Exception:
    logger.exception("Internal error processing request")
    return {"error": "An internal error occurred."}
```

---

## Path traversal

**Bad:**
```python
filepath = f"/uploads/{user_filename}"
with open(filepath) as f: ...
```

**Good:**
```python
safe_name = os.path.basename(user_filename)
filepath = os.path.join("/uploads", safe_name)
if not filepath.startswith("/uploads/"):
    raise ValueError("Invalid path")
```

---

## Insecure TLS

**Bad:**
```python
requests.get(url, verify=False)
ssl_context.check_hostname = False
```

**Good:**
```python
requests.get(url)  # verify=True is the default
# If using a custom CA: requests.get(url, verify="/path/to/ca-bundle.crt")
```

---

## Unsafe deserialization

**Bad:**
```python
import pickle
obj = pickle.loads(user_data)   # arbitrary code execution
import yaml
data = yaml.load(user_input)    # use yaml.safe_load instead
```

**Good:**
```python
import json
data = json.loads(user_input)
# or:
data = yaml.safe_load(user_input)
```

---

## Severity quick reference

| Severity | Examples |
|---|---|
| 🔴 Critical | Hardcoded production secret, RCE vector, auth bypass |
| 🟡 High | SQL injection, missing auth on sensitive endpoint, insecure deserialization |
| 🟠 Medium | Error detail leak, weak hash, hardcoded local URL in production code |
| 🟢 Low | Security TODO, over-broad CORS, verbose logging in non-sensitive path |
