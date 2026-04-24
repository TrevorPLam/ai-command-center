---
trigger: glob
globs: src/**/*.ts, src/**/*.tsx
---

# TypeScript Rules

This project uses TypeScript 5.8+ with strict mode enabled. Follow these patterns for type safety and developer experience.

<!-- SECTION: configuration -->

<configuration>

- Enable strict mode in tsconfig.json
- Enable noUncheckedIndexedAccess for array safety
- Enable noImplicitReturns for function completeness
- Enable noUnusedLocals and noUnusedParameters
- Enable exactOptionalPropertyTypes for precise optional types
- Use path aliases (@/ for src) for clean imports
- Enable skipLibCheck for faster builds
- Target ES2020+ for modern JavaScript features

</configuration>

<!-- ENDSECTION: configuration -->

<!-- SECTION: type_definitions -->

<type_definitions>

```typescript
// Use interfaces for object shapes
interface User {
  id: string;
  name: string;
  email: string;
}

// Use type aliases for unions, primitives, and utility types
type Status = 'active' | 'inactive' | 'pending';
type ID = string;
type Nullable<T> = T | null;
type Optional<T> = T | undefined;

// Use enums only when needed (prefer string unions)
enum Direction {
  Up = 'up',
  Down = 'down',
  Left = 'left',
  Right = 'right',
}
```

</type_definitions>

<!-- ENDSECTION: type_definitions -->

<!-- SECTION: generics -->

<generics>

```typescript
// Use generics for reusable components
interface Props<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  onSelect: (item: T) => void;
}

// Use constraints to limit generic types
interface HasId {
  id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

// Use default type parameters
function createArray<T = string>(length: number, defaultValue?: T): T[] {
  return Array(length).fill(defaultValue) as T[];
}
```

</generics>

<!-- ENDSECTION: generics -->

<!-- SECTION: utility_types -->

<utility_types>

```typescript
// Use built-in utility types
type PartialUser = Partial<User>;
type RequiredUser = Required<User>;
type ReadonlyUser = Readonly<User>;
type UserKeys = keyof User;
type UserValues = User[keyof User];

// Pick specific properties
type UserSummary = Pick<User, 'id' | 'name'>;

// Omit specific properties
type CreateUserInput = Omit<User, 'id'>;

// Extract return type
type AsyncFunction = () => Promise<string>;
type AsyncReturnType = ReturnType<AsyncFunction>; // Promise<string>
type AwaitedType = Awaited<AsyncReturnType>; // string
```

</utility_types>

<!-- ENDSECTION: utility_types -->

<!-- SECTION: component_typing -->

<component_typing>

```typescript
// Use React.FC for functional components
interface ButtonProps {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ children, onClick, disabled }) => {
  return <button onClick={onClick} disabled={disabled}>{children}</button>;
};

// Use forwardRef for components that need ref forwarding
export const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => {
  return <input ref={ref} {...props} />;
});
Input.displayName = 'Input';

// Use proper event types
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  console.log(e.target.value);
};

const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
};
```

</component_typing>

<!-- ENDSECTION: component_typing -->

<!-- SECTION: hook_typing -->

<hook_typing>

```typescript
// Type custom hooks properly
function useData<T>(url: string): { data: T | null; loading: boolean; error: Error | null } {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [url]);

  return { data, loading, error };
}

// Type generic hooks
function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : initialValue;
  });

  const setValue = (value: T) => {
    setStoredValue(value);
    localStorage.setItem(key, JSON.stringify(value));
  };

  return [storedValue, setValue];
}
```

</hook_typing>

<!-- ENDSECTION: hook_typing -->

<!-- SECTION: api_typing -->

<api_typing>

```typescript
// Define request and response types
interface CreateProjectRequest {
  name: string;
  status: string;
  priority: string;
  dueDate: string;
}

interface ProjectResponse {
  id: string;
  name: string;
  status: string;
  priority: string;
  dueDate: string;
  createdAt: string;
}

// Type API functions
async function createProject(data: CreateProjectRequest): Promise<ProjectResponse> {
  const response = await fetch('/api/projects', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return response.json();
}
```

</api_typing>

<!-- ENDSECTION: api_typing -->

<!-- SECTION: type_guards -->

<type_guards>

```typescript
// Use type guards for runtime type checking
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value
  );
}

// Use discriminated unions
type SuccessResponse = {
  status: 'success';
  data: unknown;
};

type ErrorResponse = {
  status: 'error';
  error: string;
};

type ApiResponse = SuccessResponse | ErrorResponse;

function handleResponse(response: ApiResponse) {
  if (response.status === 'success') {
    console.log(response.data);
  } else {
    console.error(response.error);
  }
}
```

</type_guards>

<!-- ENDSECTION: type_guards -->

<!-- SECTION: type_inference -->

<type_inference>

```typescript
// Let TypeScript infer types when possible
const users = [
  { id: '1', name: 'Alice' },
  { id: '2', name: 'Bob' },
]; // Type inferred as { id: string; name: string; }[]

// Use as const for literal types
const directions = ['up', 'down', 'left', 'right'] as const;
type Direction = typeof directions[number]; // 'up' | 'down' | 'left' | 'right'

// Use typeof for inferred types
const config = {
  apiUrl: 'http://localhost:8000',
  timeout: 5000,
};
type Config = typeof config;
```

</type_inference>

<!-- ENDSECTION: type_inference -->

<!-- SECTION: strict_mode_compliance -->

<strict_mode_compliance>

- Avoid any type (use unknown instead)
- Avoid type assertions (use type guards)
- Avoid optional chaining when value should exist
- Avoid non-null assertions (!)
- Use proper null checks
- Define all function return types
- Type all function parameters
- Use strict null checks

</strict_mode_compliance>

<!-- ENDSECTION: strict_mode_compliance -->

<!-- SECTION: error_handling -->

<error_handling>

```typescript
// Use unknown for error types
try {
  const data = await fetchData();
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message);
  } else {
    console.error('Unknown error:', error);
  }
}

// Type error boundaries
interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  ErrorBoundaryState
> {
  // ...
}
```

</error_handling>

<!-- ENDSECTION: error_handling -->

<!-- SECTION: performance -->

<performance>

- Use type annotations sparingly (let TypeScript infer)
- Use interface for object shapes, type for unions
- Avoid complex generic constraints
- Use conditional types only when necessary
- Keep type definitions simple and readable
- Use type imports for performance (import type { X } from 'y')

</performance>

<!-- ENDSECTION: performance -->

