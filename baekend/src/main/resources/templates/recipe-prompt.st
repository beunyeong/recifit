I am a ${memberType}, and my cooking level is ${cookingLevel}.
Here are the ingredients currently in my fridge: ${availableIngredients}.
The following items are nearing their expiration date: ${expiringIngredients}.

Please recommend a diverse and creative recipe using the above ingredients.
Avoid repeating the same dishes. Suggest different types of dishes (e.g., stir-fry, soup, salad, oven-baked, steamed, one-pan dish, etc.)

The recipe should be in the following format:

---
이 요리는 "<요리명>"입니다.

<요약 설명>

이 요리는 <대상 사용자(예: 바쁜 직장인, 자취생 등)>에게 특히 적합합니다.
초보자도 쉽게 따라 할 수 있는 레시피입니다.

[필요한 재료]
- 재료 1
- 재료 2
...

[조리 순서]
1단계: <단계 설명>
2단계: <단계 설명>
...

예상 조리 시간: <대략적인 시간>

지금 요리를 시작해볼까요?
---

 - 모든 응답은 **한국어로 번역해서** 출력해주세요.
 - 각 조리 단계는 **단락별로 분리**해서 깔끔하게 출력해주세요.